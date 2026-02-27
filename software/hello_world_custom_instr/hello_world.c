#include <stdlib.h>
#include <sys/alt_stdio.h>
#include <sys/times.h>
#include <alt_types.h>
#include <system.h>
#include <stdio.h>
#include <math.h>

#define LUT_SIZE 1024
#define PI       3.14159265f
#define PI_2     1.57079632f 
#define TWO_PI   6.28318530f

static inline float cust_fp_add_sub(int n, float a, float b) {
    // We must use constants here so the compiler can generate the instruction
    switch(n & ALT_CI_FP_ADD_0_N_MASK) {
        case 0: // Subtraction (if 0 is sub in your hardware)
            return __builtin_custom_fnff(ALT_CI_FP_ADD_0_N + 0, a, b);
        case 1: // Addition (if 1 is add in your hardware)
            default:
            return __builtin_custom_fnff(ALT_CI_FP_ADD_0_N + 1, a, b);
    }
}

static inline float cust_fp_mul(float a, float b) {
    // Multiplication usually doesn't have multiple 'n' modes, 
    // but we use the constant ID directly.
    return __builtin_custom_fnff(ALT_CI_FP_MUL_0_N, a, b);
}

float cos_lut_q1[LUT_SIZE + 1];
float x_vec[65281]; 

typedef struct {
    char* name;
    int n_val;
    float step_val;
} TestCase;

void init_cos_lut() {
    for (int i = 0; i <= LUT_SIZE; i++) {
        cos_lut_q1[i] = cosf((PI_2 * i) / LUT_SIZE);
    }
}

float lookup_cos(float angle) {
    float abs_angle = fabsf(angle);
    float wrapped = fmodf(abs_angle, TWO_PI);
    int index;
    if (wrapped <= PI_2) {
        index = (int)((wrapped / PI_2) * LUT_SIZE);
        return cos_lut_q1[index];
    } else if (wrapped <= PI) {
        index = (int)(((PI - wrapped) / PI_2) * LUT_SIZE);
        return -cos_lut_q1[index];
    } else if (wrapped <= (PI + PI_2)) {
        index = (int)(((wrapped - PI) / PI_2) * LUT_SIZE);
        return -cos_lut_q1[index];
    } else {
        index = (int)(((TWO_PI - wrapped) / PI_2) * LUT_SIZE);
        return cos_lut_q1[index];
    }
}

// 1. Pure Software (No Custom Floating Point Instr)
float calculateSoftwareFunctionTask6(float x[], int M) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a = x[i];
        t1 = times(NULL); 
        float cos_f = cos((a - 128.0f) / 128.0f);
        t2 = times(NULL);
        total_cos += (t2 - t1);
        y += (0.5f * a) + (a * a * a * cos_f);
    }
    printf("[cos_soft] Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

// 2. Standard cos (with Custom FP Hardware)
float calculateFunctionTask6(float x[], int M) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a = x[i];
        float a_left = cust_fp_mul(0.5f, a);
        float a_2 = cust_fp_mul(a, a);
        t1 = times(NULL); 
        float cos_f = cos((a - 128.0f) / 128.0f);
        t2 = times(NULL);
        total_cos += (t2 - t1);
        float a_cos = cust_fp_mul(a, cos_f);
        float a_right = cust_fp_mul(a_2, a_cos);
        y += cust_fp_add_sub(1, a_left, a_right);
    }
    printf("[cos_std]  Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

// 3. Standard cosf (with Custom FP Hardware)
float calculateFunctionTask6Cosf(float x[], int M) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a = x[i];
        float a_left = cust_fp_mul(0.5f, a);
        float a_2 = cust_fp_mul(a, a);
        t1 = times(NULL); 
        float cos_f = cosf((a - 128.0f) / 128.0f);
        t2 = times(NULL);
        total_cos += (t2 - t1);
        float a_cos = cust_fp_mul(a, cos_f);
        float a_right = cust_fp_mul(a_2, a_cos);
        y += cust_fp_add_sub(1, a_left, a_right);
    }
    printf("[cosf]     Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

// 4. LUT Version (with Custom FP Hardware)
float calculateFunctionTask6_LUT(float x[], int M) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a = x[i];
        float a_left = cust_fp_mul(0.5f, a);
        float a_2 = cust_fp_mul(a, a);
        float angle = (a - 128.0f) / 128.0f; 
        t1 = times(NULL);
        float cos_f = lookup_cos(angle);
        t2 = times(NULL);
        total_cos += (t2 - t1);
        float a_cos = cust_fp_mul(a, cos_f);
        float a_right = cust_fp_mul(a_2, a_cos);
        float current_val = cust_fp_add_sub(1, a_left, a_right);
        y = cust_fp_add_sub(1, y, current_val);
    }
    printf("[LUT]      Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

// Taylor series approximation for cos(x)
// For |x| <= 1, x^8/8! is ~0.00002, so x^6 is usually sufficient for float precision.
float taylor_cos(float x, int terms) {
    float x2 = cust_fp_mul(x, x);
    float sum = 1.0f; 
    float term = 1.0f;
    
    for (int n = 1; n < terms; n++) {
        // Calculate denominator: (2n-1) * 2n
        float divisor = (float)((2 * n - 1) * (2 * n));
        
        // term = term * (-x^2 / divisor)
        // Note: Using standard '/' for division unless you have a custom DIV instruction
        float next_mult = -(x2 / divisor); 
        term = cust_fp_mul(term, next_mult);
        
        // sum = sum + term (n=1 for add)
        sum = cust_fp_add_sub(1, sum, term); 
    }
    return sum;
}

// 5. Taylor Series Version (with Custom FP Hardware)
float calculateFunctionTask6_Taylor(float x[], int M, int c) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a = x[i];
        float a_left = cust_fp_mul(0.5f, a);
        float a_2 = cust_fp_mul(a, a);
        
        // Input to cos is roughly between -1.0 and 1.0
        float angle = (a - 128.0f) / 128.0f; 
        
        t1 = times(NULL);
        float cos_f = taylor_cos(angle,c);
        t2 = times(NULL);
        
        total_cos += (t2 - t1);
        
        float a_cos = cust_fp_mul(a, cos_f);
        float a_right = cust_fp_mul(a_2, a_cos);
        float current_val = cust_fp_add_sub(1, a_left, a_right);
        y = cust_fp_add_sub(1, y, current_val);
    }
    printf("[Taylor]    Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

void generateVector(float x[], int n, float step) {
    x[0] = 0;
    for (int i = 1; i < n; i++) x[i] = x[i-1] + step;
}

int main() {
    init_cos_lut();
    TestCase tests[] = {
        {"Small", 52, 5.0f},
        {"Medium", 2041, 1.0f/8.0f},
        {"Large", 65281, 1.0f/256.0f}
    };

    for (int i = 0; i < 3; i++) {
        printf("\n=== %s (N=%d) ===\n", tests[i].name, tests[i].n_val);
        generateVector(x_vec, tests[i].n_val, tests[i].step_val);

        clock_t start, end;
        
        start = times(NULL);
        float r1 = calculateSoftwareFunctionTask6(x_vec, tests[i].n_val);
        end = times(NULL);
        printf("Soft Result: %f | Total Ticks: %ld\n", r1, (long)(end-start));

        start = times(NULL);
        float r2 = calculateFunctionTask6(x_vec, tests[i].n_val);
        end = times(NULL);
        printf("Std Result:  %f | Total Ticks: %ld\n", r2, (long)(end-start));

        start = times(NULL);
        float r3 = calculateFunctionTask6Cosf(x_vec, tests[i].n_val);
        end = times(NULL);
        printf("Cosf Result: %f | Total Ticks: %ld\n", r3, (long)(end-start));

        start = times(NULL);
        float r4 = calculateFunctionTask6_LUT(x_vec, tests[i].n_val);
        end = times(NULL);
        printf("LUT Result:  %f | Total Ticks: %ld\n", r4, (long)(end-start));
        printf("Absolute Difference (Std vs LUT): %f\n", fabsf(r3 - r4));
        // for (int c = 1; c < 12; c++) {
        //   start = times(NULL);
        //   float r5 = calculateFunctionTask6_Taylor(x_vec, tests[i].n_val, c);
        //   end = times(NULL);
        //   printf("Taylor Result: %f Terms: %d | Total Ticks: %ld\n", r5, c, (long)(end-start));
        //   // printf("Absolute Difference (Std vs Taylor): %f\n", fabsf(r3 - r5));
        // }
    }
    return 0;
}