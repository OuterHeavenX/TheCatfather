#!/usr/bin/env python3
"""Re-apply the Pawfellas boot fixes to a freshly exported index.html.

Godot regenerates index.html on every web export, which drops these. Run this
straight after:

    godot --headless --path . --export-release "Web" index.html

Safe to run twice: it detects an already-patched shell and does nothing.

What it restores, and why:

  * Storage probe. Godot mounts user:// on IndexedDB via FS.syncfs(true, cb)
    with no timeout, and its init() promise has no reject path. Safari can
    leave indexedDB.open() pending forever, so the promise never settles and
    never rejects -- the splash sits at 100% with no error. We probe
    IndexedDB first and fall back to persistentPaths: [] if it does not
    answer, trading save persistence for actually booting.
  * Stall watchdog. 120s while downloading, 45s while starting, then a
    message naming the stage instead of an endless splash.
  * Stage text under the progress bar, so slow is distinguishable from stuck.
"""

import sys
from pathlib import Path

LOADER = r"""// NOTE: hand-patched after export. See "Web export" in README.md before
// regenerating this file — a plain re-export drops the boot fallbacks below.
let engine = null;

(function () {
	const statusOverlay = document.getElementById('status');
	const statusProgress = document.getElementById('status-progress');
	const statusNotice = document.getElementById('status-notice');
	const statusStage = document.getElementById('status-stage');

	// How long to wait before assuming the boot is wedged rather than slow.
	const DOWNLOAD_STALL_MS = 120000;
	const STARTUP_STALL_MS = 45000;
	// Safari can leave indexedDB.open() pending forever; don't wait on it.
	const IDB_PROBE_MS = 5000;

	let initializing = true;
	let statusMode = '';
	let stage = 'loading the engine';
	let storageState = 'not checked yet';
	let loaded = 0;
	let total = 0;
	let stallTimer = null;

	function setStatusMode(mode) {
		if (statusMode === mode || !initializing) {
			return;
		}
		if (mode === 'hidden') {
			statusOverlay.remove();
			initializing = false;
			return;
		}
		statusOverlay.style.visibility = 'visible';
		statusProgress.style.display = mode === 'progress' ? 'block' : 'none';
		statusStage.style.display = mode === 'progress' ? 'block' : 'none';
		statusNotice.style.display = mode === 'notice' ? 'block' : 'none';
		statusMode = mode;
	}

	function setStatusNotice(text) {
		while (statusNotice.lastChild) {
			statusNotice.removeChild(statusNotice.lastChild);
		}
		const lines = text.split('\n');
		lines.forEach((line) => {
			statusNotice.appendChild(document.createTextNode(line));
			statusNotice.appendChild(document.createElement('br'));
		});
	}

	function setStage(text) {
		statusStage.textContent = text;
	}

	function displayFailureNotice(err) {
		console.error(err);
		if (err instanceof Error) {
			setStatusNotice(err.message);
		} else if (typeof err === 'string') {
			setStatusNotice(err);
		} else {
			setStatusNotice('An unknown error occurred.');
		}
		setStatusMode('notice');
		initializing = false;
	}

	function mb(bytes) {
		return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
	}

	// The engine swallows errors thrown while instantiating the WASM module and
	// while mounting the IndexedDB-backed user:// filesystem: the promise it
	// returns simply never settles, leaving the splash up forever. Time it out
	// so a wedged boot says something instead of spinning.
	function armStallTimer(ms) {
		if (stallTimer !== null) {
			clearTimeout(stallTimer);
		}
		stallTimer = setTimeout(showStall, ms);
	}

	function showStall() {
		if (!initializing) {
			return;
		}
		setStatusNotice([
			'The Catfather could not finish loading.',
			'',
			'Close other browser tabs and reload — this is usually the browser',
			'running out of memory for the 40 MB engine.',
			'',
			'Stuck while: ' + stage,
			'Downloaded: ' + mb(loaded) + ' of ' + (total > 0 ? mb(total) : 'unknown'),
			'Saved games: ' + storageState,
		].join('\n'));
		setStatusMode('notice');
	}

	// Resolves true only if IndexedDB actually answers. A hang counts as a
	// failure, which is the whole point: Godot's own mount has no timeout.
	function probeStorage() {
		return new Promise((resolve) => {
			let settled = false;
			function finish(ok, why) {
				if (settled) {
					return;
				}
				settled = true;
				storageState = ok ? 'available' : 'unavailable (' + why + ')';
				resolve(ok);
			}
			const timer = setTimeout(() => finish(false, 'timed out'), IDB_PROBE_MS);
			let request = null;
			try {
				request = indexedDB.open('the-catfather-storage-probe', 1);
			} catch (err) {
				clearTimeout(timer);
				finish(false, 'blocked');
				return;
			}
			request.onsuccess = () => {
				clearTimeout(timer);
				try {
					request.result.close();
				} catch (err) {
					// Closing is best-effort; the probe already succeeded.
				}
				finish(true, 'ok');
			};
			request.onerror = () => {
				clearTimeout(timer);
				finish(false, 'refused');
			};
			request.onblocked = () => {
				clearTimeout(timer);
				finish(false, 'blocked');
			};
		});
	}

	function startEngine() {
		engine = new Engine(GODOT_CONFIG);
		setStatusMode('progress');
		setStage('Downloading…');
		stage = 'downloading the game';
		armStallTimer(DOWNLOAD_STALL_MS);

		engine.startGame({
			'onProgress': function (current, total_) {
				if (current > 0 && total_ > 0) {
					loaded = current;
					total = total_;
					statusProgress.value = current;
					statusProgress.max = total_;
					const pct = Math.floor((current / total_) * 100);
					if (current >= total_) {
						// Bytes are in; everything after this is WASM
						// instantiation and filesystem setup.
						stage = 'starting the engine';
						setStage('Starting…');
						armStallTimer(STARTUP_STALL_MS);
					} else {
						setStage('Downloading… ' + pct + '%');
					}
				} else {
					statusProgress.removeAttribute('value');
					statusProgress.removeAttribute('max');
				}
			},
		}).then(() => {
			if (stallTimer !== null) {
				clearTimeout(stallTimer);
			}
			setStatusMode('hidden');
		}, displayFailureNotice);
	}

	const missing = Engine.getMissingFeatures({
		threads: GODOT_THREADS_ENABLED,
	});

	if (missing.length !== 0) {
		if (GODOT_CONFIG['serviceWorker'] && GODOT_CONFIG['ensureCrossOriginIsolationHeaders'] && 'serviceWorker' in navigator) {
			engine = new Engine(GODOT_CONFIG);
			let serviceWorkerRegistrationPromise;
			try {
				serviceWorkerRegistrationPromise = navigator.serviceWorker.getRegistration();
			} catch (err) {
				serviceWorkerRegistrationPromise = Promise.reject(new Error('Service worker registration failed.'));
			}
			// There's a chance that installing the service worker would fix the issue
			Promise.race([
				serviceWorkerRegistrationPromise.then((registration) => {
					if (registration != null) {
						return Promise.reject(new Error('Service worker already exists.'));
					}
					return registration;
				}).then(() => engine.installServiceWorker()),
				// For some reason, `getRegistration()` can stall
				new Promise((resolve) => {
					setTimeout(() => resolve(), 2000);
				}),
			]).then(() => {
				// Reload if there was no error.
				window.location.reload();
			}).catch((err) => {
				console.error('Error while registering service worker:', err);
			});
		} else {
			// Display the message as usual
			const missingMsg = 'Error\nThe following features required to run Godot projects on the Web are missing:\n';
			displayFailureNotice(missingMsg + missing.join('\n'));
		}
	} else {
		setStatusMode('progress');
		setStage('Checking storage…');
		probeStorage().then((ok) => {
			if (!ok) {
				// Mounting user:// would hang here. Run without it: progress
				// is lost between sessions, but the game boots.
				console.warn('IndexedDB unavailable, running without persistent saves:', storageState);
				GODOT_CONFIG['persistentPaths'] = [];
			}
			startEngine();
		});
	}
}());"""

OLD_POS = """#status, #status-splash, #status-progress {
	position: absolute;
	left: 0;
	right: 0;
}"""
NEW_POS = """#status, #status-splash, #status-progress, #status-stage {
	position: absolute;
	left: 0;
	right: 0;
}"""

OLD_CSS = """#status-progress, #status-notice {
	display: none;
}
"""
NEW_CSS = """#status-progress, #status-notice, #status-stage {
	display: none;
}

#status-stage {
	bottom: 5%;
	color: #b9a7c4;
	font-family: 'Noto Sans', 'Droid Sans', Arial, sans-serif;
	font-size: 0.85rem;
	padding: 0 1rem;
	text-align: center;
}
"""

OLD_BODY = """			<progress id="status-progress"></progress>
			<div id="status-notice"></div>"""
NEW_BODY = """			<progress id="status-progress"></progress>
			<div id="status-stage"></div>
			<div id="status-notice"></div>"""


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "index.html")
    html = path.read_text()

    if "probeStorage" in html:
        print(f"{path}: already patched, nothing to do")
        return 0

    for old in (OLD_POS, OLD_CSS, OLD_BODY):
        if old not in html:
            print(f"{path}: expected block not found -- did the Godot shell change?",
                  file=sys.stderr)
            return 1

    html = html.replace(OLD_POS, NEW_POS, 1)
    html = html.replace(OLD_CSS, NEW_CSS, 1)
    html = html.replace(OLD_BODY, NEW_BODY, 1)

    start = html.index("const engine = new Engine(GODOT_CONFIG);")
    end = html.index("}());", start) + len("}());")
    html = html[:start] + LOADER + html[end:]

    path.write_text(html)
    print(f"{path}: boot fixes applied")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
