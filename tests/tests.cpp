#include "../src/buffers_management.hpp"
#include <gtest/gtest.h>
#include <iostream>

extern "C" void mtrx_mul(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w,
                            float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix);

namespace
{
    const uint32_t MAX_SIZE = 19;
    float *buffer;
    float *matrix1, *matrix2, *matrix3, *matrix4;
    
    void trivial_mtrx_mul(float *m1, uint32_t height1, uint32_t width1, float *m2,
                            uint32_t width2, float *m3)
    {
        for (uint32_t i = 0; i < height1; ++i) {
            for (uint32_t j = 0; j < width2; ++j) {
                for (uint32_t k = 0; k < width1; ++k) {
                    matrix3[i * width2 + j] += matrix1[i * width1 + k] * matrix2[k * width2 + j];
                }
            }
        }
    }
    void fill_matricies()
    {
        for (uint32_t i = 0; i < MAX_SIZE; ++i) {
            for (uint32_t j = 0; j < MAX_SIZE; ++j) {
                matrix1[i * MAX_SIZE + j] = rand() % 3 / 2.0;
                matrix2[i * MAX_SIZE + j] = rand() % 3 / 2.0;
                matrix3[i * MAX_SIZE + j] = matrix4[i * MAX_SIZE + j] = 0;
        }
    }
    }

    TEST(MTRX_MUL, TEST_16x16)
    {
        uint32_t size = 16;
        ASSERT_LT(size, MAX_SIZE);
        fill_matricies();
        trivial_mtrx_mul(matrix1, size, size, matrix2, size, matrix3);
        mtrx_mul(matrix1, size, size, matrix2, size, matrix4);
        for (uint32_t i = 0; i < size; ++i) {
            for (uint32_t j = 0; j < size; ++j) {
                ASSERT_FLOAT_EQ(matrix3[i * size + j], matrix4[i * size + j]);
            }
        }
    }

    TEST(MTRX_MUL, TEST_19x16_16x16)
    {
        uint32_t size1 = 19, size2 = 16;
        ASSERT_LT(size1 * size2, MAX_SIZE * MAX_SIZE);
        fill_matricies();
        trivial_mtrx_mul(matrix1, size1, size2, matrix2, size2, matrix3);
        mtrx_mul(matrix1, size1, size2, matrix2, size2, matrix4);
        for (uint32_t i = 0; i < size1; ++i) {
            for (uint32_t j = 0; j < size2; ++j) {
                ASSERT_FLOAT_EQ(matrix3[i * size2 + j], matrix4[i * size2 + j]);
            }
        }
    }
}

int main(int argc, char **argv)
{
    buffer = allocate_buffer(16 * MAX_SIZE);
    auto matricies = allocate_matricies(MAX_SIZE * MAX_SIZE, 32, 4);
    matrix1 = matricies[0];
    matrix2 = matricies[1];
    matrix3 = matricies[2];
    matrix4 = matricies[3];
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}