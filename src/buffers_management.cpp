#include "buffers_management.hpp"

#include <iostream>
#include <malloc.h>

float *matricies[MAX_MATRICIES_AMOUNT];
float *buffer;

float *allocate_buffer(uint32_t size, size_t align)
{
    buffer = (float *)_aligned_malloc(size * sizeof(*buffer), align);
    return buffer;
}

float **allocate_matricies(uint32_t size, size_t align, int matricies_amount)
{
    if (matricies_amount > MAX_MATRICIES_AMOUNT) {
        std::cerr << "matrcies_amount is bigger than max value. matricies_amount = " << matricies_amount <<
            ", max = " << MAX_MATRICIES_AMOUNT;
        exit(1);
    }
    for (int i = 0; i < matricies_amount; ++i) {
        matricies[i] = (float *)_aligned_malloc(size * sizeof(**matricies), align);
    }
    return matricies;
}

void free_buffer()
{
    _aligned_free(buffer);
}

void free_matricies()
{
    int i = 0;
    for (float **matricies_ptr = matricies; *matricies_ptr && i < MAX_MATRICIES_AMOUNT; ++matricies_ptr, ++i) {
        _aligned_free(matricies[i]);
    }
}