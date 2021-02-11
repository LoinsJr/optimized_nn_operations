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
    
    std::cout << "Test\n";
    for (int i = 0; i < 6; ++i) {
        for (int j = 0; j < 3; ++j) {
            matrix1[i * 8 + j] = j % 3;
        }
    }
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 18; ++j) {
            matrix2[i * 24 + j] = j % 18;
        }
    }
    mtrx_mul(matrix1, 6, 3, matrix2, 18, matrix3);
    for (uint32_t i = 0; i < 6; ++i) {
        for (uint32_t j = 0; j < 18; ++j) {
            std::cout << matrix3[i * 24 + j] << ' ';
        }
        std::cout << std::endl;
    }
    std::cout << "Done\n";
    /*
    mtrx_mul(matrix1, SIZE, SIZE, matrix2, SIZE, matrix3);
    auto s = start_measuring();
    mtrx_mul(matrix1, SIZE, SIZE, matrix2, SIZE, matrix3);
    std::cout << (end_measuring() - s) / CLOCK_FREQUENCY;
    */
    free_float_matricies();
    return 0;
}