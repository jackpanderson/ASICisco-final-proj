import wave
import numpy as np

# Load your WAV file (must be mono 16-bit PCM)
wav = wave.open('forg96kmono.wav', 'rb')
assert wav.getnchannels() == 1
assert wav.getsampwidth() == 2
assert wav.getframerate() == 96000

samples = np.frombuffer(wav.readframes(wav.getnframes()), dtype=np.int16)
wav.close()

# Normalize to unsigned 24-bit and write to hex file
samples_24bit = np.left_shift(samples.astype(np.int32), 8)  # Shift to MSB for 24-bit
with open('forg_wav_data.hex', 'w') as f:
    for sample in samples_24bit:
        f.write(f'{(sample & 0xFFFFFF):06x}\n')
