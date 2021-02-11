#include "buffers_management.hpp"
#include <gtest/gtest.h>
#include <iostream>

extern "C" void mtrx_mul(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w,
                            float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix);

namespace
{
    const uint32_t MAX_SIZE = 24;
    float *buffer;
    float *matrix1, *matrix2, *matrix3, *matrix4, *matrix5, *matrix6;
    
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

    TEST(MTRX_MUL, TEST_18x17_17x18)
    {
        uint32_t size1 = 17, size2 = 18, size2_multiply_of_8 = 24;
        ASSERT_LT(size1 * size2, MAX_SIZE * MAX_SIZE);
        fill_matricies();
        float *matrix2_ptr = matrix2;
        for (uint32_t i = 0; i < size1; ++i) {
            for (uint32_t j = 0; j < size2; ++j) {
                matrix5[i * size2_multiply_of_8 + j] = *matrix2_ptr++;
            }
        }
        trivial_mtrx_mul(matrix1, size1, size2, matrix2, size1, matrix3);
        mtrx_mul(matrix1, size1, size2, matrix5, size1, matrix4);
        for (uint32_t i = 0; i < size1; ++i) {
            for (uint32_t j = 0; j < size2; ++j) {
                ASSERT_FLOAT_EQ(matrix3[i * size2 + j], matrix5[i * size2_multiply_of_8 + j]);
            }
        }
    }
}

int main(int argc, char **argv)
{
    auto matricies = allocate_float_matricies(6, 32, MAX_SIZE);
    matrix1 = matricies[0];
    matrix2 = matricies[1];
    matrix3 = matricies[2];
    matrix4 = matricies[3];
    matrix5 = matricies[4];
    matrix6 = matricies[5];
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}