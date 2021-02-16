#include "buffers_management.hpp"
#include <gtest/gtest.h>
#include <iostream>

uint32_t MAX_SIZE = 24;
float *matrix1, *matrix2, *matrix3, *matrix4, *matrix5, *matrix6;

int main(int argc, char **argv)
{
    auto matricies = allocate_float_matricies(7, 32, MAX_SIZE * MAX_SIZE);
    matrix1 = matricies[0];
    matrix2 = matricies[1];
    matrix3 = matricies[2];
    matrix4 = matricies[3];
    matrix5 = matricies[4];
    matrix6 = matricies[5];
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}