#pragma once
#define MAX_MATRICIES_AMOUNT 4

#include <cinttypes>

float *allocate_buffer(uint32_t size, size_t align = 32);

// Returns array of matricies
float **allocate_matricies(uint32_t size, size_t align = 32, int matricies_amount = 1);

void free_buffer();

void free_matricies();