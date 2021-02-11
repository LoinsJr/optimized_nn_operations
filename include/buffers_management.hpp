#pragma once
#define MAX_MATRICIES_AMOUNT 7

#include <cinttypes>

float **allocate_float_matricies(int matricies_amount, size_t align, uint32_t size);

void free_float_matricies();