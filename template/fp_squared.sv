`include "defs.sv"

module fp_squared(
    input logic [31:0]  x,
    output logic [31:0] x_squared
);
    
    wire [7:0] exp = x[30:23];
    wire [22:0] mant = x[22:0];
    wire [7:0] exp_out = (exp<<1) - 8'd127;
    wire [45:0] mant_square = mant*mant;
    wire [22:0] mant_out = (mant<<1) + mant_square[45:23]; // (1+2m+m^2) 1 is inferred

    assign x_squared = {1'b0,exp_out,mant_out};

endmodule


#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include <string.h>
#include "system.h"
#include "io.h"              // For IORD/IOWR
#include "sys/alt_cache.h"
#include "altera_msgdma.h"
#include "altera_msgdma_descriptor_regs.h"
#include "altera_msgdma_csr_regs.h"

// --- Register Map (Byte Offsets for Nios II) ---
// Address 0 -> Offset 0: Status (bit 0 is Done)
// Address 1 -> Offset 4: Result Y
// Address 2 -> Offset 8: Heartbeat/Word Counter (If you added it to Verilog)
#define WRAPPER_BASE        PIPELINED_FSM_0_BASE
#define REG_DONE_OFFSET     0
#define REG_RESULT_OFFSET   4
#define REG_COUNT_OFFSET    8

// Use a safe area in On-Chip RAM
#define DATA_BUFFER_BASE    (ONCHIP_MEM_BASE + 0x20000) 

static inline float bits2f(uint32_t b) {
    float f;
    memcpy(&f, &b, 4);
    return f;
}

void generate_vector(float *ptr, int n, float step) {
    ptr[0] = 0.0f; // Start with 1.0 to avoid early zeros
    for (int i = 1; i < n; i++)
        ptr[i] = ptr[i-1] + step;
}

float hw_compute(int n) {
    alt_msgdma_dev *dma = alt_msgdma_open(MSGDMA_0_CSR_NAME);
    if (!dma) { printf("  [ERROR] Could not open SGDMA\n"); return -1.0f; }

    IOWR_ALTERA_MSGDMA_CSR_STATUS(MSGDMA_0_CSR_BASE, 0xFFFFFFFF);
    alt_dcache_flush((void*)DATA_BUFFER_BASE, n * sizeof(float));

    alt_msgdma_standard_descriptor desc;
    alt_msgdma_construct_standard_mm_to_st_descriptor(
        dma, &desc,
        (uint32_t*)DATA_BUFFER_BASE,
        n * sizeof(float),
        ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MASK
    );

    alt_msgdma_standard_descriptor_sync_transfer(dma, &desc);

    uint32_t dma_stat = IORD_ALTERA_MSGDMA_CSR_STATUS(MSGDMA_0_CSR_BASE);
    printf("  [DEBUG] SGDMA CSR: 0x%08X\n", (unsigned int)dma_stat);

    // *** FIX: poll sticky_done at offset 0, not word_count at offset 8 ***
    uint32_t timeout = 0;
    while (!(IORD_32DIRECT(WRAPPER_BASE, REG_DONE_OFFSET) & 0x1)) {
        if (timeout++ > 5000000) {
            printf("  [TIMEOUT] last_valid_word=%f eop=%f\n",
                bits2f(IORD_32DIRECT(WRAPPER_BASE, REG_COUNT_OFFSET)),  // ← correct
                bits2f(IORD_32DIRECT(WRAPPER_BASE, 12)));
            IORD_32DIRECT(WRAPPER_BASE, REG_RESULT_OFFSET); // reset wrapper
            printf("  [TIMEOUT] whatever_has_been_accumulated=%f eop=%lu\n",
                bits2f(IORD_32DIRECT(WRAPPER_BASE, REG_RESULT_OFFSET)));
            return -1.0f;
        }
    }

    uint32_t raw_y = IORD_32DIRECT(WRAPPER_BASE, REG_RESULT_OFFSET);
    printf("  [HW] Done. raw=0x%08X\n", (unsigned int)raw_y);
    printf("  [HW] last_valid_word=%f eop=%f\n",
                bits2f(IORD_32DIRECT(WRAPPER_BASE, REG_COUNT_OFFSET)),  // ← correct
                bits2f(IORD_32DIRECT(WRAPPER_BASE, 8)));
    return bits2f(raw_y);
}
// Software reference
float ref_compute(int n, float step) {
    float sum = 0.0;
    float val = 0.0f;  // ← was 1.0f
    for (int i = 0; i < n; i++) {
        sum += (double)val * (0.5 + (double)val*val * cos((val - 128.0) / 128.0));
        val += step;
    }
    return (float)sum;
}

int main(void) {
    printf("\n--- SGDMA Hardware Test Start ---\n");

    int n_sizes[] = {52, 2041}; // Focus on Small and Medium first
    float steps[] = {1.0f, 0.125f};

    for (int i = 0; i < 2; i++) {
        int n = n_sizes[i];
        printf("\nTEST CASE: N = %d\n", n);

        generate_vector((float*)DATA_BUFFER_BASE, n, steps[i]);

        float expected = ref_compute(n, steps[i]);
        printf("  [SW] Expected: %.2f\n", expected);

        float got = hw_compute(n);
        printf("  [HW] Got:      %.2f\n", got);

        if (got != -1.0f && fabsf(got - expected) < 10.0f) {
            printf("  RESULT: PASS\n");
        } else {
            printf("  RESULT: FAIL\n");
        }
    }

    printf("\n--- Test End ---\n");
    return 0;
}