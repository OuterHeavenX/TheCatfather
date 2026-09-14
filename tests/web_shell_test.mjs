// Behavioral checks for the actual exported loader, using stubbed browser/Engine
// APIs and a deterministic clock. This is not a Safari device test.
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';

// HTML declares UTF-8. Windows' default code page must never leak into it.
const html = new TextDecoder('utf-8', { fatal: true }).decode(readFileSync(process.argv[2] || 'index.html'));
const inline = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].at(-1)[1];
assert.match(inline, /GODOT_THREADS_ENABLED = false/);

async function boot(storage, engineMode = 'ready') {
  let now = 0, sequence = 0, config, started = 0;
  const timers = new Map(), warnings = [], errors = [];
  function element() {
    return { style: {}, textContent: '', value: 0, max: 0, children: [], removed: false,
      appendChild(child) { this.children.push(child); },
      removeChild() { this.children.pop(); },
      get lastChild() { return this.children.at(-1); },
      removeAttribute() {}, remove() { this.removed = true; } };
  }
  const elements = Object.fromEntries(['status','status-progress','status-notice','status-stage'].map(id => [id, element()]));
  class Engine {
    static getMissingFeatures() { return []; }
    constructor(c) { config = c; }
    startGame(options) {
      started++;
      options.onProgress(100, 100);
      if (engineMode === 'hang') return new Promise(() => {});
      if (engineMode === 'reject') return Promise.reject(new Error('test engine failure'));
      return Promise.resolve();
    }
  }
  const context = {
    Engine, navigator: {}, window: {}, Error,
    document: { getElementById: id => elements[id], createTextNode: text => text, createElement: () => element() },
    console: { warn: (...args) => warnings.push(args), error: (...args) => errors.push(args) },
    setTimeout(fn, delay) { const id = ++sequence; timers.set(id, { fn, at: now + delay }); return id; },
    clearTimeout(id) { timers.delete(id); },
    indexedDB: { open() {
      if (storage === 'throw') throw new Error('blocked');
      const request = { result: { close() {} } };
      if (storage !== 'hang') queueMicrotask(() => {
        if (storage === 'healthy') request.onsuccess();
        else if (storage === 'blocked') request.onblocked();
        else request.onerror();
      });
      return request;
    } },
  };
  vm.runInNewContext(inline, context);
  const settle = async () => { for (let i = 0; i < 8; i++) await Promise.resolve(); };
  await settle();
  async function advance(ms) {
    now += ms;
    for (const [id, timer] of timers) if (timer.at <= now) { timers.delete(id); timer.fn(); }
    await settle();
  }
  if (storage === 'hang') await advance(5000);
  return { elements, warnings, errors, advance, config, started };
}

const healthy = await boot('healthy');
assert.equal(healthy.started, 1);
assert.equal(healthy.config.persistentPaths, undefined);
assert.equal(healthy.elements.status.removed, true);
console.log('PASS healthy storage preserves engine persistence configuration');
for (const mode of ['throw', 'error', 'blocked', 'hang']) {
  const result = await boot(mode);
  assert.equal(result.started, 1);
  assert.equal(result.config.persistentPaths.length, 0);
  assert.equal(result.elements.status.removed, true);
  assert.equal(result.warnings.length, 1);
  console.log(`PASS ${mode} storage boots in volatile mode (console warning only)`);
}
const stalled = await boot('healthy', 'hang');
await stalled.advance(45000);
assert.equal(stalled.elements['status-notice'].style.display, 'block');
assert.match(stalled.elements['status-notice'].children.join(' '), /could not finish loading/);
console.log('PASS stalled engine surfaces startup notice');
const rejected = await boot('healthy', 'reject');
assert.equal(rejected.errors.length, 1);
assert.equal(rejected.elements['status-notice'].style.display, 'block');
console.log('PASS rejected engine surfaces error notice');
console.log('WEB SHELL TESTS OK');
