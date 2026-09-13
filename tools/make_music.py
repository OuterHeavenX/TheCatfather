#!/usr/bin/env python3
"""Synthesise the speakeasy jazz loop used as Pawfellas' background music.

No sample library is involved: everything here is additive synthesis plus
filtered noise, written to a seamless mono WAV. Note tails wrap around the
end of the buffer so the loop joins without a click.

    python3 tools/make_music.py assets/audio/speakeasy_loop.wav
"""

import math
import struct
import sys
import wave
from pathlib import Path

import numpy as np

SR = 22050
BPM = 104.0
BEAT = 60.0 / BPM
BARS = 8
LOOP = BEAT * 4 * BARS
N = int(round(LOOP * SR))
SWING = 0.62          # first eighth takes 62% of the beat

rng = np.random.default_rng(7)


def midi(n):
    return 440.0 * (2.0 ** ((n - 69) / 12.0))


def add(buf, start, sig, gain=1.0):
    """Mix sig into buf at sample `start`, wrapping past the end."""
    i = int(start) % N
    end = i + len(sig)
    if end <= N:
        buf[i:end] += sig * gain
    else:
        cut = N - i
        buf[i:] += sig[:cut] * gain
        buf[:end - N] += sig[cut:] * gain


def env(n, attack, decay, sustain=0.0, release=None):
    e = np.zeros(n)
    a = max(1, int(attack * SR))
    d = max(1, int(decay * SR))
    e[:a] = np.linspace(0, 1, a)
    tail = n - a
    if tail > 0:
        dd = min(d, tail)
        e[a:a + dd] = np.linspace(1, sustain, dd)
        if tail > dd:
            e[a + dd:] = sustain
    if release:
        r = min(int(release * SR), n)
        e[-r:] *= np.linspace(1, 0, r)
    return e


def upright_bass(note, dur):
    n = int(dur * SR)
    t = np.arange(n) / SR
    f = midi(note)
    sig = (np.sin(2 * np.pi * f * t)
           + 0.45 * np.sin(4 * np.pi * f * t)
           + 0.18 * np.sin(6 * np.pi * f * t))
    # finger thump
    sig += 0.5 * rng.normal(0, 1, n) * np.exp(-t * 90)
    return sig * env(n, 0.004, dur * 0.9, 0.05, dur * 0.3)


def piano_chord(notes, dur, detune=1.0):
    n = int(dur * SR)
    t = np.arange(n) / SR
    sig = np.zeros(n)
    for k, note in enumerate(notes):
        f = midi(note) * detune
        for h, amp in ((1, 1.0), (2, 0.42), (3, 0.22), (4, 0.12), (5, 0.06)):
            sig += amp * np.sin(2 * np.pi * f * h * t + k) * np.exp(-t * (2.6 + h * 1.3))
    return sig * env(n, 0.003, dur, 0.0)


def muted_trumpet(note, dur):
    n = int(dur * SR)
    t = np.arange(n) / SR
    f = midi(note)
    vib = 1.0 + 0.006 * np.sin(2 * np.pi * 5.4 * t) * np.minimum(1.0, t * 5)
    sig = np.zeros(n)
    for h, amp in ((1, 1.0), (2, 0.55), (3, 0.40), (4, 0.22), (5, 0.14), (6, 0.07)):
        sig += amp * np.sin(2 * np.pi * f * h * t * vib)
    sig *= env(n, 0.035, dur * 0.7, 0.55, dur * 0.35)
    return sig


def brush(dur, bright=1.0):
    n = int(dur * SR)
    t = np.arange(n) / SR
    noise = rng.normal(0, 1, n)
    # one-pole lowpass, brighter values let more hiss through
    a = math.exp(-2 * math.pi * (1400 * bright) / SR)
    out = np.zeros(n)
    prev = 0.0
    for i in range(n):
        prev = a * prev + (1 - a) * noise[i]
        out[i] = prev
    return out * np.exp(-t * 26)


# Dm7 | Dm7 | Gm7 | Gm7 | A7 | A7 | Dm7 | A7
CHORDS = [
    ([62, 65, 69, 72], [38, 41, 45, 48]),
    ([62, 65, 69, 72], [38, 45, 48, 45]),
    ([67, 70, 74, 77], [43, 46, 50, 53]),
    ([67, 70, 74, 77], [43, 50, 53, 50]),
    ([69, 73, 76, 79], [45, 49, 52, 55]),
    ([69, 73, 76, 79], [45, 52, 55, 52]),
    ([62, 65, 69, 72], [38, 41, 45, 48]),
    ([69, 73, 76, 79], [45, 52, 55, 51]),
]

MELODY = [  # (bar, beat, midi note, beats long)
    (0, 2.0, 74, 1.0), (0, 3.0, 72, 0.5), (0, 3.5, 69, 1.5),
    (2, 2.0, 77, 1.0), (2, 3.0, 74, 1.0),
    (4, 1.5, 76, 0.5), (4, 2.0, 73, 1.0), (4, 3.0, 69, 1.0),
    (6, 2.0, 72, 0.5), (6, 2.5, 74, 0.5), (6, 3.0, 69, 2.0),
]


def build():
    bass = np.zeros(N)
    keys = np.zeros(N)
    horn = np.zeros(N)
    drums = np.zeros(N)

    for bar in range(BARS):
        chord, walk = CHORDS[bar]
        bar_start = bar * 4 * BEAT
        for b in range(4):
            at = (bar_start + b * BEAT) * SR
            add(bass, at, upright_bass(walk[b], BEAT * 0.92), 0.22)
            # ride pattern: downbeat plus the swung "and"
            add(drums, at, brush(BEAT * 0.5, 1.0), 0.13)
            add(drums, at + BEAT * SWING * SR, brush(BEAT * 0.4, 1.25), 0.085)
            if b in (1, 3):     # comp on 2 and 4
                add(keys, at, piano_chord(chord, BEAT * 1.1), 0.17)

    for bar, beat, note, length in MELODY:
        at = (bar * 4 * BEAT + (beat - 1) * BEAT) * SR
        add(horn, at, muted_trumpet(note, length * BEAT * 0.95), 0.26)

    mix = bass + keys + horn + drums
    # tilt: add back a high-passed copy so the tune survives a phone speaker
    hp = np.empty_like(mix)
    prev_in = prev_out = 0.0
    coef = math.exp(-2 * math.pi * 700.0 / SR)
    for i in range(len(mix)):
        prev_out = coef * (prev_out + mix[i] - prev_in)
        prev_in = mix[i]
        hp[i] = prev_out
    mix = mix + 0.9 * hp
    # a little vinyl: hiss, and a gentle wow in level
    mix += rng.normal(0, 1, N) * 0.0028
    t = np.arange(N) / SR
    mix *= 1.0 + 0.02 * np.sin(2 * np.pi * 0.7 * t)
    # soft clip, then normalise with headroom
    mix = np.tanh(mix * 1.25)
    mix /= max(1e-9, np.abs(mix).max())
    return (mix * 0.82 * 32767).astype(np.int16)


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "assets/audio/speakeasy_loop.wav")
    out.parent.mkdir(parents=True, exist_ok=True)
    samples = build()
    with wave.open(str(out), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", s) for s in samples))
    print("%s: %.1fs, %d Hz mono, %.0f KB"
          % (out, len(samples) / SR, SR, out.stat().st_size / 1024))


if __name__ == "__main__":
    main()
