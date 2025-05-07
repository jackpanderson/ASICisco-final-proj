import math
import struct

# Convert Q8.16 hex string to float
def q816_to_float(hex_str):
    val = int(hex_str, 16)
    if val & 0x80000000:
        val -= 1 << 32  # Handle signed 32-bit
    return val / (1 << 16)

# Convert float to Q8.16 int
def float_to_q816(val):
    return int(round(val * (1 << 16))) & 0xFFFFFFFF

# Convert float to hex Q8.16 string
def float_to_q816_hex(val):
    return f"{float_to_q816(val):08X}"

# Print all conversions
def process_q816_angle(hex_input):
    print(f"Input Q8.16 Hex: 0x{hex_input}")
    
    angle_rad = q816_to_float(hex_input)
    print(f"Angle in radians (float): {angle_rad:.6f}")
    
    sin_val = math.sin(angle_rad)
    cos_val = math.cos(angle_rad)

    sin_q816 = float_to_q816_hex(sin_val)
    cos_q816 = float_to_q816_hex(cos_val)

    print(f"sin(angle):")
    print(f"  Q8.16 Hex: 0x{sin_q816}")
    print(f"  Float   : {sin_val:.6f}")
    
    print(f"cos(angle):")
    print(f"  Q8.16 Hex: 0x{cos_q816}")
    print(f"  Float   : {cos_val:.6f}")

# Example usage
if __name__ == "__main__":
    # Replace this with your input hex
    while(1):
        input_hex = input("Enter Q8.16 hex angle (e.g. 00019220 for ~π/2): ").strip().lstrip("0x").zfill(8)
        process_q816_angle(input_hex)
