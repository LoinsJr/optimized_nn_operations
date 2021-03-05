#include <cinttypes>
#include <gtest/gtest.h>

extern uint32_t MAX_SIZE;
extern float *matrix1, *matrix2, *matrix3, *matrix4, *matrix5, *matrix6;
extern float *buffer;

extern "C" void mtrx_mul_(const float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w,
                        const float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix, float *buffer);

TEST(MTRX_MUL, TEST_16x16)
{
    ASSERT_LT(16 * 16, MAX_SIZE * MAX_SIZE);
    for (int i = 0; i < 16 * 16; ++i) {
        matrix1[i] = rand() % 3 / 2.0;
        matrix2[i] = rand() % 3 / 2.0;
    }
    mtrx_mul_(matrix1, 16, 16, matrix2, 16, matrix3, buffer);
    for (int i = 0; i < 16; ++i) {
        for (int j = 0; j < 16; ++j) {
            float res = 0;
            for (int k = 0; k < 16; ++k) {
                res += matrix1[i * 16 + k] * matrix2[k * 16 + j];
            }
            ASSERT_FLOAT_EQ(matrix3[i * 16 + j], res);
        }
    }
}

TEST(MTRX_MUL, TEST_22x11_11x16)
{
    ASSERT_LT(22 * 11, MAX_SIZE * MAX_SIZE);
    for (int i = 0; i < 22; ++i) {
        for (int j = 0; j < 11; ++j) {
            matrix1[i * 16 + j] = rand() % 3 / 2.0;
        }
    }
    for (int i = 0; i < 11; ++i) {
        for (int j = 0; j < 16; ++j) {
            matrix1[i * 16 + j] = rand() % 3 / 2.0;
        }
    }
    mtrx_mul_(matrix1, 22, 11, matrix2, 16, matrix3, buffer);
    for (int i = 0; i < 22; ++i) {
        for (int j = 0; j < 16; ++j) {
            float res = 0;
            for (int k = 0; k < 11; ++k) {
                res += matrix1[i * 16 + k] * matrix2[k * 16 + j];
            }
            ASSERT_FLOAT_EQ(matrix3[i * 16 + j], res);
        }
    }
}

TEST(MTRX_MUL, TEST_17x12_12x18)
{
    ASSERT_LT(12 * 18, MAX_SIZE * MAX_SIZE);
    for (int i = 0; i < 17; ++i) {
        for (int j = 0; j < 12; ++j) {
            matrix1[i * 16 + j] = rand() % 3 / 2.0;
        }
    }
    for (int i = 0; i < 12; ++i) {
        for (int j = 0; j < 18; ++j) {
            matrix2[i * 24 + j] = rand() % 3 / 2.0;
        }
    }
    mtrx_mul_(matrix1, 17, 12, matrix2, 18, matrix3, buffer);
    for (int i = 0; i < 17; ++i) {
        for (int j = 0; j < 18; ++j) {
            float res = 0;
            for (int k = 0; k < 12; ++k) {
                res += matrix1[i * 16 + k] * matrix2[k * 24 + j];
            }
            ASSERT_FLOAT_EQ(matrix3[i * 24 + j], res);
        }
    }
}

TEST(MTRX_MUL, TEST_15x12_12x23)
{
    ASSERT_LT(12 * 23, MAX_SIZE * MAX_SIZE);
    for (int i = 0; i < 15; ++i) {
        for (int j = 0; j < 12; ++j) {
            matrix1[i * 16 + j] = rand() % 3 / 2.0;
        }
    }
    for (int i = 0; i < 12; ++i) {
        for (int j = 0; j < 23; ++j) {
            matrix2[i * 24 + j] = rand() % 3 / 2.0;
        }
    }
    mtrx_mul_(matrix1, 15, 12, matrix2, 23, matrix3, buffer);
    for (int i = 0; i < 15; ++i) {
        for (int j = 0; j < 23; ++j) {
            float res = 0;
            for (int k = 0; k < 12; ++k) {
                res += matrix1[i * 16 + k] * matrix2[k * 24 + j];
            }
            if (matrix3[i * 24 + j] != res) {
                std::cout << i << ' ' << j << '\n';
            }
            ASSERT_FLOAT_EQ(matrix3[i * 24 + j], res);
        }
    }
}