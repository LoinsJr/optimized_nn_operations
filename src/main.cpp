#include <processthreadsapi.h>
#include <synchapi.h>

#include "buffers_management.hpp"
#include "compare_execution_time.hpp"

using namespace std;

extern float *buffer;

extern "C" void mtrx_mul_(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w,
                            float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix);
extern "C" void mtrx_mul_async_(void *params);

int main(int argc, char **argv)
{
    const uint32_t SIZE = 1024;
    float **matricies = allocate_float_matricies(5, 32, SIZE * SIZE);
    float *matrix1 = matricies[0], *matrix2 = matricies[1], *matrix3 = matricies[2];
    uint64_t params[6];
    params[0] = reinterpret_cast<uint64_t>(matrix1);
    params[3] = reinterpret_cast<uint64_t>(matrix2);
    params[5] = reinterpret_cast<uint64_t>(matrix3);
    params[1] = params[2] = params[4] = SIZE;
    auto s = start_measuring();
    mtrx_mul_async_(params);
    cout << (end_measuring() - s) / CLOCK_FREQUENCY << '\n';
    return 0;
}