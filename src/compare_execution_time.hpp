#pragma once

#include <cinttypes>
#include <iomanip>
#include <iostream>

#define CLOCK_FREQUENCY 1.8e9

extern "C" uint64_t start_measuring();
extern "C" uint64_t end_measuring();

template <class TReturn, class... TArgs>
void compare_execution_time(const int laps_amount, const int iterations_amount,
                            TReturn (*func1)(TArgs...), TReturn (*func2)(TArgs...), TArgs... args)
{
    uint64_t total_score1 = 0, total_score2 = 0;
    std::cout << "----------------------------------------------\n";
    std::cout << "Lap # | func1(cycles, seconds) | func2(cycles, seconds) | Result\n";
    for (int lap = 0; lap < laps_amount; ++lap) {
        std::cout << std::setw(5) << lap << "   ";
        uint64_t total_cycles1 = 0;
        func1(args...);
        for (int iteration = iterations_amount; iteration != 0; --iteration) {
            uint64_t cycles = start_measuring();
            func1(args...);
            total_cycles1 += end_measuring() - cycles;
        }
        total_cycles1 /= iterations_amount;
        std::cout << std::setw(12) << total_cycles1 << ", " << std::setw(7) <<
                    std::fixed << std::setprecision(5) << total_cycles1 / CLOCK_FREQUENCY << "    ";
        uint64_t total_cycles2 = 0;
        func2(args...);
        for (int iteration = iterations_amount; iteration != 0; --iteration) {
            uint64_t cycles = start_measuring();
            func2(args...);
            total_cycles2 += end_measuring() - cycles;
        }
        total_cycles2 /= iterations_amount;
        std::cout << std::setw(12) << total_cycles2 << ", " << std::setw(7) <<
                    std::fixed << std::setprecision(5) << total_cycles2 / CLOCK_FREQUENCY << "    ";
        if (total_cycles1 < total_cycles2) {
            std::cout << "func1 wins, +" << total_cycles2 - total_cycles1 << std::endl;
            total_score1 += total_cycles2 - total_cycles1;
        } else {
            std::cout << "func2 wins, +" << total_cycles1 - total_cycles2 << std::endl;
            total_score2 += total_cycles1 - total_cycles2;
        }
    }
    std::cout << "RESULT. func1: " << total_score1 << "; func2: " << total_score2 << '\n';
    std::cout << "----------------------------------------------\n";
}