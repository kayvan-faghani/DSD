#include <stdlib.h>
#include <sys/alt_stdio.h>
#include <sys/times.h>
#include <alt_types.h>
#include <system.h>
#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include <string.h>
#include "io.h"
#include "sys/alt_cache.h"
#include "altera_msgdma.h"
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"

#define LUT_SIZE 1024
#define PI       3.14159265f
#define PI_2     1.57079632f 
#define TWO_PI   6.28318530f

#define WRAPPER_BASE      PIPELINED_FSM_0_BASE
#define REG_DONE_OFFSET   0
#define REG_RESULT_OFFSET 4
#define DATA_BUFFER_BASE  (ONCHIP_MEM_BASE + 0x10000)

static inline float cust_fp_add_sub(int n, float a, float b) {
    switch(n & ALT_CI_FP_ADD_0_N_MASK) {
        case 0: return __builtin_custom_fnff(ALT_CI_FP_ADD_0_N + 0, a, b);
        case 1: default: return __builtin_custom_fnff(ALT_CI_FP_ADD_0_N + 1, a, b);
    }
}
static inline float cust_fp_mul(float a, float b) {
    return __builtin_custom_fnff(ALT_CI_FP_MUL_0_N, a, b);
}
static inline float cust_cos(float a) {
    return __builtin_custom_fnff(ALT_CI_CORDIC_0_N, a, a);
}
static inline float cust_function(float a) {
    return __builtin_custom_fnff(ALT_CI_FUNC_FSM_0_N, a, a);
}

static inline float bits2f(uint32_t b) {
    float f; memcpy(&f, &b, 4); return f;
}

float cos_lut_q1[LUT_SIZE + 1];
float x_vec[65281]; 

typedef struct {
    char* name;
    int   n_val;
    float step_val;
} TestCase;

void init_cos_lut() {
    for (int i = 0; i <= LUT_SIZE; i++)
        cos_lut_q1[i] = cosf((PI_2 * i) / LUT_SIZE);
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

void generateVector(float x[], int n, float step) {
    x[0] = 0;
    for (int i = 1; i < n; i++) x[i] = x[i-1] + step;
}

// 1. Pure Software
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

// 2. Standard cos (Custom FP)
float calculateFunctionTask6(float x[], int M) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a = x[i];
        float a_left = cust_fp_mul(0.5f, a);
        float a_2    = cust_fp_mul(a, a);
        t1 = times(NULL);
        float cos_f = cos((a - 128.0f) / 128.0f);
        t2 = times(NULL);
        total_cos += (t2 - t1);
        float a_cos   = cust_fp_mul(a, cos_f);
        float a_right = cust_fp_mul(a_2, a_cos);
        y += cust_fp_add_sub(1, a_left, a_right);
    }
    printf("[cos_std]  Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

// 3. cosf (Custom FP)
float calculateFunctionTask6Cosf(float x[], int M) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a = x[i];
        float a_left = cust_fp_mul(0.5f, a);
        float a_2    = cust_fp_mul(a, a);
        t1 = times(NULL);
        float cos_f = cosf((a - 128.0f) / 128.0f);
        t2 = times(NULL);
        total_cos += (t2 - t1);
        float a_cos   = cust_fp_mul(a, cos_f);
        float a_right = cust_fp_mul(a_2, a_cos);
        y += cust_fp_add_sub(1, a_left, a_right);
    }
    printf("[cosf]     Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

// 4. CORDIC Custom Instruction
float calculateFunctionTask7Cordic(float x[], int M) {
    int i; float y = 0;
    clock_t t1, t2, total_cos = 0;
    for (i = 0; i < M; i++) {
        float a   = x[i];
        float a_2 = cust_fp_mul(a, a);
        t1 = times(NULL);
        float cos_f = cust_cos(cust_fp_add_sub(0, a, 128.0f) / 128.0f);
        t2 = times(NULL);
        total_cos += (t2 - t1);
        float a_right  = cust_fp_mul(a_2, cos_f);
        float brackets = cust_fp_add_sub(1, 0.5f, a_right);
        float curr     = cust_fp_mul(a, brackets);
        y = cust_fp_add_sub(1, y, curr);
    }
    printf("[Cordic]   Total Cos Ticks: %ld | Avg: %f\n", (long)total_cos, (float)total_cos/M);
    return y;
}

// 5. Full Custom Instruction (Task 7)
float calculateFunctionTask7Full(float x[], int M) {
    float y = 0;
    for (int i = 0; i < M; i++)
        y = cust_fp_add_sub(1, y, cust_function(x[i]));
    return y;
}

// 6. Task 8 — SGDMA + Pipelined Hardware Accelerator
float calculateFunctionTask8SGDMA(float x[], int M) {
    alt_msgdma_dev *dma = alt_msgdma_open(MSGDMA_0_CSR_NAME);
    if (!dma) { printf("  [ERROR] Could not open SGDMA\n"); return -1.0f; }

    // IOWR_ALTERA_MSGDMA_CSR_STATUS(MSGDMA_0_CSR_BASE, 0xFFFFFFFF);
    
    // Flush cache for x directly — no copy needed
    alt_dcache_flush(x, M * sizeof(float));

    alt_msgdma_standard_descriptor desc;
    alt_msgdma_construct_standard_mm_to_st_descriptor(
        dma, &desc,
        (uint32_t*)x,          // ← pass x directly
        M * sizeof(float),
        ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MASK
    );
    alt_msgdma_standard_descriptor_sync_transfer(dma, &desc);

    // printf("[SGDMA]    CSR: 0x%08X\n",
    //        (unsigned int)IORD_ALTERA_MSGDMA_CSR_STATUS(MSGDMA_0_CSR_BASE));

    uint32_t timeout = 0;
    while (!(IORD_32DIRECT(WRAPPER_BASE, REG_DONE_OFFSET) & 0x1)) {
        // if (timeout++ > 5000000) {
        //     printf("[SGDMA]    TIMEOUT\n");
        //     return -1.0f;
        // }
    }

    uint32_t raw = IORD_32DIRECT(WRAPPER_BASE, REG_RESULT_OFFSET);
    uint32_t fx = IORD_32DIRECT(WRAPPER_BASE, 8);
    uint32_t word_count = IORD_32DIRECT(WRAPPER_BASE, 12);
    printf("[SGDMA]    raw=0x%08X last_fx=0x%f word_count=%ld\n", (unsigned int)raw, (float)fx, (uint32_t)word_count);
    return bits2f(raw);
}

int main() {
    init_cos_lut();

    TestCase tests[] = {
        {"Tiny",   10,    1.0f},
        {"Small",  52,    5.0f},
        {"Medium", 2041,  1.0f/8.0f},
        {"Large",  65281, 1.0f/256.0f}
    };

    for (int i = 0; i < 4; i++) {
        printf("\n=== %s (N=%d) ===\n", tests[i].name, tests[i].n_val);
        generateVector(x_vec, tests[i].n_val, tests[i].step_val);

        clock_t start, end;

        // start = times(NULL);
        // float r1 = calculateSoftwareFunctionTask6(x_vec, tests[i].n_val);
        // end = times(NULL);
        // printf("Soft Result:        %f | Total Ticks: %ld\n", r1, (long)(end-start));

        // start = times(NULL);
        // float r2 = calculateFunctionTask6(x_vec, tests[i].n_val);
        // end = times(NULL);
        // printf("Std Result:         %f | Total Ticks: %ld\n", r2, (long)(end-start));

        start = times(NULL);
        float r3 = calculateFunctionTask6Cosf(x_vec, tests[i].n_val);
        end = times(NULL);
        printf("Cosf Result:        %f | Total Ticks: %ld\n", r3, (long)(end-start));

        // start = times(NULL);
        // float r6 = calculateFunctionTask7Cordic(x_vec, tests[i].n_val);
        // end = times(NULL);
        // printf("Cordic Result:      %f | Total Ticks: %ld\n", r6, (long)(end-start));
        // printf("Diff (Cosf vs Cordic):       %f\n", fabsf(r3 - r6));

        // start = times(NULL);
        // float r7 = calculateFunctionTask7Full(x_vec, tests[i].n_val);
        // end = times(NULL);
        // printf("Cordic Full Result: %f | Total Ticks: %ld\n", r7, (long)(end-start));
        // printf("Diff (Cosf vs Cordic Full):  %f\n", fabsf(r3 - r7));

        // Task 8 — skip Large (65281 elements may exceed on-chip buffer)
        // if (tests[i].n_val <= 2041) {
        start = times(NULL);
        float r8 = calculateFunctionTask8SGDMA(x_vec, tests[i].n_val);
        end = times(NULL);
        if (r8 != -1.0f) {
            printf("SGDMA Result:       %f | Total Ticks: %ld\n", r8, (long)(end-start));
            printf("Diff (Cosf vs SGDMA):        %f\n", fabsf(r3 - r8));
            int pass = fabsf(r3 - r8) / fabsf(r3) < 0.02f;
            printf("SGDMA: %s\n", pass ? "PASS" : "FAIL");
        } else {
            printf("SGDMA Result:       TIMEOUT/ERROR\n");
        }
        // } else {
        //     printf("SGDMA Result:       SKIPPED (N too large for on-chip buffer)\n");
        // }
    }

    return 0;
}