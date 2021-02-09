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
    const uint32_t SIZE = 16;
    const int N_LAPS = 10;
    const int N_ITERATIONS = 1;
    float *buffer = allocate_buffer(16 * (SIZE + 3));
    float **matricies = allocate_matricies((SIZE + 3) * SIZE, 32, 3);
    float *matrix1 = matricies[0], *matrix2 = matricies[1], *matrix3 = matricies[2];
    for (uint32_t i = 0; i < (SIZE + 3) * SIZE; ++i) {
        matrix1[i] = i % SIZE + i;
        matrix2[i] = i % SIZE;
    }
    
    mtrx_mul(matrix1, SIZE + 3, SIZE, matrix2, SIZE, matrix3);
    for (uint32_t i = 0; i < SIZE + 3; ++i) {
        for (uint32_t j = 0; j < SIZE; ++j) {
            std::cout << matrix3[i * SIZE + j] << ' ';
        }
        std::cout << std::endl;
    }
    
    mtrx_mul(matrix1, SIZE, SIZE, matrix2, SIZE, matrix3);
    auto s = start_measuring();
    mtrx_mul(matrix1, SIZE, SIZE, matrix2, SIZE, matrix3);
    std::cout << (end_measuring() - s) / CLOCK_FREQUENCY;
    
    free_matricies();
    free_buffer();
    return 0;
}