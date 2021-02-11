#include "buffers_management.hpp"
#include "compare_execution_time.hpp"

extern "C" void count_kernel_4x16(float *src_matrix1, uint32_t src_matrix1_w, float *src_matrix2,
                                    uint32_t src_matrix2_w, float *dst_matrix);

extern "C" void mtrx_mul(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w,
                            float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix);

extern "C" void old_mtrx_mul(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w,
                            float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix);

int main(int argc, char **argv)
{
    const uint32_t SIZE = 24;
    const int N_LAPS = 10;
    const int N_ITERATIONS = 1;
    float **matricies = allocate_float_matricies(4, 32, SIZE * SIZE);
    float *matrix1 = matricies[0], *matrix2 = matricies[1], *matrix3 = matricies[2];

    free_float_matricies();
    return 0;
}