#include <cinttypes>
#include <gtest/gtest.h>

extern uint32_t MAX_SIZE;
extern float *matrix1, *matrix2, *matrix3, *matrix4, *matrix5, *matrix6;

extern "C" void reorder_src_matrix1_debug(float *src_matrix, uint32_t height, uint32_t width,
            uint64_t width_real, float *dst_matrix);

TEST(REORDER_MTRX, REORDER_SRC_MATRIX1_18_17)
{
    ASSERT_LT(18 * 17, MAX_SIZE * MAX_SIZE);
    for (int i = 0; i < 18 * 17; ++i) {
        matrix1[i] = rand() % 3 / 2.0;
    }
    reorder_src_matrix1_debug(matrix1, 18, 17, 24 * sizeof(float), matrix2);
    float *ptr_matrix2 = matrix2;
    for (int i = 0; i < 18; i += 6) {
        for (int j = 0; j < 17; ++j) {
            ASSERT_FLOAT_EQ(matrix1[i * 24 + j], *ptr_matrix2++);
            ASSERT_FLOAT_EQ(matrix1[(i + 1) * 24 + j], *ptr_matrix2++);
            ASSERT_FLOAT_EQ(matrix1[(i + 2) * 24 + j], *ptr_matrix2++);
            ASSERT_FLOAT_EQ(matrix1[(i + 3) * 24 + j], *ptr_matrix2++);
            ASSERT_FLOAT_EQ(matrix1[(i + 4) * 24 + j], *ptr_matrix2++);
            ASSERT_FLOAT_EQ(matrix1[(i + 5) * 24 + j], *ptr_matrix2++);
        }
    }
}