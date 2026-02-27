import random
from math import atan, sin, cos, pi, sqrt
import statistics
import numpy as np

# ============================
# Generate fixed-point tables
# ============================

def make_tables(frac_bits, iters):

    SCALE = 1 << frac_bits

    def float_to_fixed(x):
        return int(round(x * SCALE))

    z_table = [float_to_fixed(atan(2**-i)) for i in range(iters)]

    k = 1.0
    for i in range(iters):
        k *= 1 / sqrt(1 + 2**(-2*i))

    K_fixed = float_to_fixed(k)

    return SCALE, z_table, K_fixed


# ============================
# Fixed-point CORDIC
# ============================

def cordic_fixed(angle_fixed, frac_bits, z_table, K_fixed):

    SCALE = 1 << frac_bits

    x = SCALE
    y = 0
    z = 0

    for i, atan_val in enumerate(z_table):

        sigma = 1 if z < angle_fixed else -1

        x_new = x - sigma * (y >> i)
        y_new = y + sigma * (x >> i)
        z += sigma * atan_val

        x, y = x_new, y_new

    x = (x * K_fixed) >> frac_bits
    y = (y * K_fixed) >> frac_bits

    return x, y


# ============================
# Monte Carlo test
# ============================

def monte_carlo_bits(frac_bits, iters, samples=10000):

    SCALE, z_table, K_fixed = make_tables(frac_bits, iters)

    sin_errors = []
    cos_errors = []

    for _ in range(samples):

        angle = np.float32(random.uniform(-1, 1))

        angle_fixed = int(round(angle * SCALE))

        cos_fixed, sin_fixed = cordic_fixed(
            angle_fixed,
            frac_bits,
            z_table,
            K_fixed
        )

        cos_val = cos_fixed / SCALE

        cos_errors.append(abs(cos_val - np.cos(angle, dtype=np.float32)))

    return {
        "iters": frac_bits,
        "cos_max": max(cos_errors),
        "cos_mse": statistics.mean(e*e for e in cos_errors)
    }

def monte_carlo_iters(frac_bits, iters, samples=10000):

    SCALE, z_table, K_fixed = make_tables(frac_bits, iters)

    sin_errors = []
    cos_errors = []

    for _ in range(samples):

        angle = np.float32(random.uniform(-1, 1))

        angle_fixed = int(round(angle * SCALE))

        cos_fixed, sin_fixed = cordic_fixed(
            angle_fixed,
            frac_bits,
            z_table,
            K_fixed
        )

        cos_val = cos_fixed / SCALE

        cos_errors.append(abs(cos_val - np.cos(angle, dtype=np.float32)))

    return {
        "iters": iters,
        "cos_max": max(cos_errors),
        "cos_mse": statistics.mean(e*e for e in cos_errors)
    }

# ============================
# Run sweep
# ============================

if __name__ == "__main__":

    print("bits   sin_max      sin_rms      cos_max      cos_rms")
    starting_frac_bits = 30
    optimal_iters = 0
    for iters in range (1,30,1):
        result = monte_carlo_iters(starting_frac_bits, iters, samples=20000)

        if (result["cos_mse"] < 2.4*(10**-11)):
            print("First result which meets timing is: ")
            print(
                f"{result['frac_bits']:2d}   "
                f"{result['cos_max']:.8f}   "
                f"{result['cos_mse']:.8f}"
            )
            optimal_iters = iters
            break

    for bits in range(4, 33, 1):

        result = monte_carlo_bits(bits, optimal_iters, samples=20000)
        if (result["cos_mse"] < 2.4*(10**-11)) :
            print(
                f"{result['frac_bits']:2d}   "
                f"{result['cos_max']:.8f}   "
                f"{result['cos_mse']:.8f}"
            )
    
    
