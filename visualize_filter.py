import re
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import freqz, tf2zpk

SAMPLE_RATE = 96000

def parse_coefficients_from_text(raw_text):
    # Use regex to extract coefficients and their floating-point values inside parentheses
    b = []
    a = []
    lines = raw_text.strip().splitlines()

    for line in lines:
        # Regex to extract the coefficients and their corresponding values in parentheses
        match = re.match(r'(b|a)(\d):\s*(-?\d+)\s?\(([-+]?\d*\.\d+|\d+)\)', line)
        if match:
            coeff_type, index, value, float_value = match.groups()
            index = int(index)
            value = float(value)
            float_value = float(float_value)

            if coeff_type == 'b':
                while len(b) <= index:
                    b.append(0.0)  # Ensure b has enough space for all coefficients
                b[index] = float_value
            elif coeff_type == 'a':
                while len(a) <= index:
                    a.append(0.0)  # Ensure a has enough space for all coefficients
                a[index] = float_value

    return b, a

def main():
    print("Paste the filter coefficient block, then press Ctrl-D (or Ctrl-Z on Windows):")
    try:
        raw_text = ""
        while True:
            line = input()
            raw_text += line + "\n"
    except EOFError:
        pass

    b, a = parse_coefficients_from_text(raw_text)

    temp = b
    b = a
    a = temp

    if not b or not a:
        print("Could not extract valid filter coefficients.")
        return

    print("Extracted b coefficients:", b)
    print("Extracted a coefficients:", a)

    # Frequency response
    w, h = freqz(b, a, worN=1024, fs=SAMPLE_RATE)

    plt.figure(figsize=(12, 6))

    # Magnitude response
    plt.subplot(1, 2, 1)
    plt.plot(w, 20 * np.log10(abs(h)), label='Magnitude (dB)')
    plt.title('Frequency Response')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude (dB)')
    plt.grid(True)

    # Pole-zero plot
    plt.subplot(1, 2, 2)
    z, p, _ = tf2zpk(b, a)
    unit_circle = plt.Circle((0, 0), 1, fill=False, linestyle='dashed', color='gray')
    plt.gca().add_artist(unit_circle)
    plt.scatter(np.real(z), np.imag(z), marker='o', label='Zeros')
    plt.scatter(np.real(p), np.imag(p), marker='x', label='Poles')
    plt.title('Pole-Zero Plot')
    plt.xlabel('Real')
    plt.ylabel('Imaginary')
    plt.axis('equal')
    plt.grid(True)
    plt.legend()

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()
