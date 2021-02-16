#include "buffers_management.hpp"
#include "compare_execution_time.hpp"

extern "C" void count_kernel_4x16(float *src_matrix1, uint32_t src_matrix1_w, float *src_matrix2,
                                    uint32_t src_matrix2_w, float *dst_matrix);

extern "C" inline void mtrx_mul_debug(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w,
                            float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix);

extern "C" float *reorder_src_matrix1_debug(float *src_matrix, uint32_t height, uint32_t width,
            uint64_t width_real, float *dst_matrix);

int main(int argc, char **argv)
{
    const uint32_t SIZE = 1024;
    const int N_LAPS = 10;
    const int N_ITERATIONS = 1;
    float **matricies = allocate_float_matricies(5, 32, SIZE * SIZE);
    float *matrix1 = matricies[0], *matrix2 = matricies[1], *matrix3 = matricies[2];
    mtrx_mul_debug(matrix1, 1024, 1024, matrix2, 1024, matrix3);
    auto s = start_measuring();
    mtrx_mul_debug(matrix1, 1024, 1024, matrix2, 1024, matrix3);
    std::cout << (end_measuring() - s) / CLOCK_FREQUENCY << '\n';
    free_float_matricies();
    return 0;
}