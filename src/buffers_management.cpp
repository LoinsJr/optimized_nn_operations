#include "buffers_management.hpp"

#include <iostream>
#include <malloc.h>

float *matricies[MAX_MATRICIES_AMOUNT - 1];
float *buffer;

namespace
{
    int _matricies_amount;
}

float **allocate_float_matricies(int matricies_amount, size_t align, uint32_t size)
{
    if (matricies_amount > MAX_MATRICIES_AMOUNT) {
        std::cerr << "matrcies_amount is bigger than max value. matricies_amount = " << matricies_amount <<
            ", max = " << MAX_MATRICIES_AMOUNT;
        exit(1);
    }
    for (int i = 0; i < matricies_amount - 2; ++i) {
        matricies[i] = (float *)_aligned_malloc(size * sizeof(**matricies), align);
    }
    if (matricies_amount >= 1) {
        buffer = (float *)_aligned_malloc(size * sizeof(**matricies), align);
    }
    _matricies_amount = matricies_amount;
    return matricies;
}

void free_float_matricies()
{
    for (int i = 0; i < _matricies_amount - 1; ++i) {
        _aligned_free(matricies[i]);
    }
    if (_matricies_amount >= 1) {
        _aligned_free(buffer);
    }
}