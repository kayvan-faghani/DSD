import math
import struct

def float_to_hex(f):
    # Converts a float to its IEEE-754 32-bit hex string
    return format(struct.unpack('<I', struct.pack('<f', f))[0], '08x')

def generate_cos_hex(filename, depth=256):
    with open(filename, 'w') as f:
        for i in range(depth):
            # Scale index i (0-255) to radians (0 to pi/2)
            angle = (i / (depth - 1)) * (math.pi / 2)
            val = math.cos(angle)
            f.write(float_to_hex(val) + "\n")

generate_cos_hex("cos_lut.hex")
print("cos_lut.hex has been generated.")