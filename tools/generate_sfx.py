#!/usr/bin/env python3
"""Procedural 8-bit style SFX generator for SciQuest.

Pure standard-library synthesis (no numpy) -> 16-bit mono WAV files written
into ../sound/. Re-run any time to regenerate. Royalty-free; everything here
is generated from scratch.

Usage:  python tools/generate_sfx.py
"""

import math
import os
import random
import struct
import wave

SAMPLE_RATE = 22050
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "sound")

# ── Core synthesis helpers ─────────────────────────────────────────────────

def _n(seconds):
    return int(seconds * SAMPLE_RATE)

def silence(seconds):
    return [0.0] * _n(seconds)

def square(freq, seconds, duty=0.5, vol=0.5):
    out = []
    period = SAMPLE_RATE / freq if freq > 0 else 1
    for i in range(_n(seconds)):
        phase = (i % period) / period
        out.append(vol if phase < duty else -vol)
    return out

def sine(freq, seconds, vol=0.5):
    out = []
    for i in range(_n(seconds)):
        out.append(vol * math.sin(2 * math.pi * freq * i / SAMPLE_RATE))
    return out

def sweep(f0, f1, seconds, vol=0.5, kind="square", duty=0.5):
    """Frequency glide from f0 to f1."""
    out = []
    total = _n(seconds)
    phase = 0.0
    for i in range(total):
        t = i / total
        freq = f0 + (f1 - f0) * t
        phase += freq / SAMPLE_RATE
        if kind == "square":
            out.append(vol if (phase % 1.0) < duty else -vol)
        else:
            out.append(vol * math.sin(2 * math.pi * phase))
    return out

def noise(seconds, vol=0.5):
    return [random.uniform(-1, 1) * vol for _ in range(_n(seconds))]

def lowpass(samples, alpha=0.2):
    """Simple one-pole low-pass to soften noise into a 'whoosh'."""
    out = []
    prev = 0.0
    for s in samples:
        prev = prev + alpha * (s - prev)
        out.append(prev)
    return out

def envelope(samples, attack=0.01, release=0.05):
    """Linear attack/release fade to avoid clicks."""
    out = list(samples)
    a = max(1, _n(attack))
    r = max(1, _n(release))
    for i in range(min(a, len(out))):
        out[i] *= i / a
    for i in range(min(r, len(out))):
        out[-1 - i] *= i / r
    return out

def mix(*tracks):
    """Overlay tracks of possibly-different lengths."""
    length = max(len(t) for t in tracks)
    out = [0.0] * length
    for t in tracks:
        for i, s in enumerate(t):
            out[i] += s
    return out

def seq(*tracks):
    """Concatenate tracks back-to-back."""
    out = []
    for t in tracks:
        out.extend(t)
    return out

def arp(freqs, note_len, vol=0.5, duty=0.5, kind="square"):
    """Arpeggio: a quick run of notes."""
    parts = []
    for f in freqs:
        if kind == "square":
            parts.append(envelope(square(f, note_len, duty, vol), 0.005, note_len * 0.4))
        else:
            parts.append(envelope(sine(f, note_len, vol), 0.005, note_len * 0.4))
    return seq(*parts)

def save(name, samples):
    # Soft-clip / normalise to avoid distortion when tracks were mixed.
    peak = max((abs(s) for s in samples), default=1.0)
    norm = 0.9 / peak if peak > 0.9 else 1.0
    path = os.path.join(OUT_DIR, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            v = int(max(-1.0, min(1.0, s * norm)) * 32767)
            frames += struct.pack("<h", v)
        w.writeframes(frames)
    print("  wrote", name, f"({len(samples)/SAMPLE_RATE:.2f}s)")

# ── Note table (just the few we need) ──────────────────────────────────────
C4, D4, E4, F4, G4, A4, B4 = 261.6, 293.7, 329.6, 349.2, 392.0, 440.0, 493.9
C5, E5, G5, C6 = 523.3, 659.3, 784.0, 1046.5
G3, C3 = 196.0, 130.8

# ── Individual sounds ───────────────────────────────────────────────────────

def s_dash():
    # Fast falling filtered-noise whoosh.
    body = lowpass(noise(0.18, 0.7), 0.08)
    body = envelope(body, 0.005, 0.12)
    air = envelope(sweep(900, 200, 0.18, 0.18, "sine"), 0.01, 0.1)
    return mix(body, air)

def s_slide():
    # Gritty sustained scrape.
    body = lowpass(noise(0.28, 0.6), 0.05)
    return envelope(body, 0.02, 0.18)

def s_land():
    # Low thud + short noise scuff.
    thud = envelope(sweep(180, 70, 0.12, 0.7, "sine"), 0.002, 0.1)
    scuff = envelope(lowpass(noise(0.08, 0.4), 0.05), 0.002, 0.07)
    return mix(thud, scuff)

def s_correct():
    # Happy ascending triad.
    return arp([C5, E5, G5, C6], 0.09, vol=0.45, duty=0.5)

def s_wrong():
    # Descending buzzy "uh-oh".
    a = envelope(square(220, 0.16, 0.5, 0.45), 0.005, 0.06)
    b = envelope(square(165, 0.22, 0.5, 0.45), 0.005, 0.12)
    return seq(a, b)

def s_chest_open():
    # Creak (noise) then bright reward chime.
    creak = envelope(lowpass(noise(0.12, 0.35), 0.04), 0.02, 0.08)
    chime = arp([E5, G5, C6], 0.10, vol=0.4)
    return seq(creak, silence(0.02), chime)

def s_checkpoint():
    # Soft confirming two-note chime (sine, gentle).
    return arp([G4, C5, E5], 0.11, vol=0.4, kind="sine")

def s_orb_pickup():
    # Classic coin: quick two-note up.
    a = envelope(square(B4, 0.05, 0.5, 0.4), 0.002, 0.02)
    b = envelope(square(E5, 0.12, 0.5, 0.4), 0.002, 0.09)
    return seq(a, b)

def s_generator_power():
    # Rising power-up hum.
    hum = envelope(sweep(120, 520, 0.45, 0.5, "square", 0.5), 0.02, 0.15)
    shine = envelope(arp([C5, E5, G5, C6], 0.06, 0.22), 0.005, 0.12)
    return mix(hum, seq(silence(0.2), shine))

def s_mirror_rotate():
    # Short mechanical tick/click.
    a = envelope(square(640, 0.04, 0.5, 0.35), 0.001, 0.035)
    b = envelope(lowpass(noise(0.03, 0.25), 0.1), 0.001, 0.025)
    return mix(a, b)

def s_crystal_lit():
    # Bright shimmer with a little sparkle tail.
    body = arp([C5, G5, C6], 0.10, vol=0.35, kind="sine")
    sparkle = envelope(sine(1568, 0.18, 0.18), 0.02, 0.16)  # G6-ish
    return mix(body, seq(silence(0.12), sparkle))

SOUNDS = {
    "dash.wav":            s_dash,
    "slide.wav":           s_slide,
    "land.wav":            s_land,
    "answer correct.wav":  s_correct,
    "answer wrong.wav":    s_wrong,
    "chest open.wav":      s_chest_open,
    "checkpoint.wav":      s_checkpoint,
    "orb pickup.wav":      s_orb_pickup,
    "generator power.wav": s_generator_power,
    "mirror rotate.wav":   s_mirror_rotate,
    "crystal lit.wav":     s_crystal_lit,
}

def main():
    random.seed(42)  # deterministic output across runs
    os.makedirs(OUT_DIR, exist_ok=True)
    print("Generating SFX into", os.path.normpath(OUT_DIR))
    for name, fn in SOUNDS.items():
        save(name, fn())
    print("Done:", len(SOUNDS), "files.")

if __name__ == "__main__":
    main()
