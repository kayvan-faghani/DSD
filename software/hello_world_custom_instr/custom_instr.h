#ifndef FP_CUSTOM_INSTR_H
#define FP_CUSTOM_INSTR_H

#include <stdint.h>
#include "../hello_world_custom_instr_bsp/system.h"

#undef  ALT_CI_CORDIC_0
#define ALT_CI_CORDIC_0(A,B)   __builtin_custom_fnff(ALT_CI_CORDIC_0_N, (A), (B))

#undef  ALT_CI_FP_ADD_0
#define ALT_CI_FP_ADD_0(n,A,B) __builtin_custom_fnff(ALT_CI_FP_ADD_0_N + (n & 0x1), (A), (B))

#undef  ALT_CI_FP_MUL_0
#define ALT_CI_FP_MUL_0(A,B)   __builtin_custom_fnff(ALT_CI_FP_MUL_0_N, (A), (B))

// static inline uint32_t f2u(float x){
//     union { float f; uint32_t u; } v;
//     v.f = x;
//     return v.u;
// }

// static inline float u2f(uint32_t x){
//     union { uint32_t u; float f; } v;
//     v.u = x;
//     return v.f;
// }

// static inline float cust_fp_mul(float a, float b){
//     uint32_t r = ALT_CI_FP_MUL_0(f2u(a), f2u(b));
//     return u2f(r);
// }

// static inline float cust_fp_add_sub(int n, float a, float b){
//     uint32_t r;
    
//     // Using constants (0 and 1) instead of the variable 'n' 
//     // inside the macro fixes the "compile-time constant" error.
//     if (n == 0) {
//         r = ALT_CI_FP_ADD_0(0, f2u(a), f2u(b)); // Add
//     } else {
//         r = ALT_CI_FP_ADD_0(1, f2u(a), f2u(b)); // Subtract
//     }
    
//     return u2f(r);
// }

#endif