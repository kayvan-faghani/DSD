import random
import math
import statistics
import numpy as np

# 

def make_tables(frac_bits, iters):
    SCALE = 1 << frac_bits
    z_table = [int(round(math.atan(2**-i) * SCALE)) for i in range(iters)]
    
    k = 1.0
    for i in range(iters):
        k *= 1 / math.sqrt(1 + 2**(-2*i))

    hex_list = [hex(value) for value in z_table]
    K_fixed = int(round(k * SCALE))
    print(f"Iters: {iters} Frac bits: {frac_bits} K: {hex(K_fixed)} Atans: {hex_list}")
    return SCALE, z_table, K_fixed

def cordic_fixed(angle_fixed, frac_bits, z_table, K_fixed, show=False):
    # CRITICAL CHANGE: Initialize x with K_fixed (0.607...) 
    # This prevents the values from growing beyond the bit-limit.
    x, y, z = K_fixed, 0, angle_fixed
    
    mask = (1 << (frac_bits + 2)) - 1 # 22-bit mask for uhex
    sign_bit = 1 << (frac_bits + 1)   # bit 21 for a 22-bit number

    def uhex(val):
        return hex(val & mask)

    if (show):
        print(f"Z table: {[hex(value) for value in z_table]}")

    for i, atan_val in enumerate(z_table):
        # 1. Check the sign bit (bit 21)
        if not (z & sign_bit):
            # Positive angle: Rotate Clockwise
            x_new = x - (y >> i)
            y_new = y + (x >> i)
            z = z - atan_val
            if (show):
                print(f"Sign bit was not set so Z operation performed was {x} - {(y>>i)}")
        else:
            # Negative angle: Rotate Counter-Clockwise
            x_new = x + (y >> i)
            y_new = y - (x >> i)
            z = z + atan_val
            if (show):
                print(f"Sign bit was set so Z operation performed was {x} + {(y>>i)}")
        
        x, y = x_new, y_new
        
        if show:
            print(f"Stage {i}: x={uhex(x)}, y={uhex(y)}, z={uhex(z)}")

    # No multiplication needed at the end if x started as K_fixed!
    return x, y

def run_test(frac_bits, iters, samples=15000):
    SCALE, z_table, K_fixed = make_tables(frac_bits, iters)
    sq_errors = []

    for _ in range(samples):
        # Using float64 for the reference to avoid floor-noise from float32
        angle = random.uniform(-1, 1)
        angle_fixed = int(round(angle * SCALE))

        cos_fixed, _ = cordic_fixed(angle_fixed, frac_bits, z_table, K_fixed)
        
        ref = math.cos(angle)
        calc = cos_fixed / SCALE
        sq_errors.append((calc - ref)**2)

    mse = statistics.mean(sq_errors)
    sem = statistics.stdev(sq_errors) / math.sqrt(samples)
    upper_bound_95 = mse + (1.96 * sem)

    return mse, upper_bound_95, z_table, K_fixed

if __name__ == "__main__":
    TARGET_MSE = 2.4e-11
    SAMPLES = 20000
    
    # Search ranges
    iter_range = range(15, 30) # CORDIC roughly gains 1 bit of prec per iteration
    bit_range = range(20, 45)
    
    results = []

    print(f"Grid Search for MSE < {TARGET_MSE}...")
    print(f"{'Iters':<6} | {'FracBits':<10} | {'MSE':<15}| {'95% UB MSE':<15} | {'Cost (Bits*Iters)'}")
    print("-" * 60)

    for iters in iter_range:
        for bits in bit_range:
            mse, ub, z_table, K_fixed = run_test(bits, iters, samples=SAMPLES)
            
            if ub < TARGET_MSE:
                # Total Wordlength = FracBits + 1 (Sign) + 1 (Integer/Gain)
                total_wl = bits + 2 
                cost = iters * total_wl
                results.append((iters, bits, ub, cost, z_table, K_fixed))
                print(f"{iters:<6} | {bits:<10} | {mse:.2e} | {ub:.2e} | {cost}")
                # Once we find a bit-width that works for this 'iters', 
                # incrementing 'bits' further will only increase cost.
                break 

    if results:
        # Sort by total bit cost (efficiency)
        best = min(results, key=lambda x: x[3])
        print("\n" + "="*30)
        print("OPTIMAL CONFIGURATION FOUND")
        print("="*30)
        print(f"Stages (Iters):   {best[0]}")
        print(f"Fractional Bits:  {best[1]}")
        print(f"Total Wordlength: {best[1] + 2} bits")
        print(f"Efficiency Cost:  {best[3]} bit-ops")
        print(f"Verified MSE UB:  {best[2]:.2e}")
        print(hex(best[5]))
        print(hex(cordic_fixed(0x700000,best[1],best[4],best[5],True)[0]))
        print(hex(cordic_fixed(0x080000,best[1],best[4],best[5],True)[0]))
        print(hex(cordic_fixed(0x100000,best[1],best[4],best[5],True)[0]))
    else:
        print("No configuration met the target. Increase search ranges.")