ASM_SRCS = $(wildcard src/*.asm)
ASM_OBJS = $(patsubst src/%.asm, %.o, $(ASM_SRCS))

prog: prog.exe
	prog.exe

tests: tests/tests.exe
	tests/tests.exe

tests/tests.exe: buffers_management.o $(ASM_OBJS) tests/tests.o
	g++ -m64 $^ -lgtest -lgtest_main -o tests/tests.exe

prog.exe: buffers_management.o $(ASM_OBJS) main.o
	g++ -m64 $^ -o prog.exe

tests/tests.o: tests/tests.cpp
	g++ -O2 -m64 -c $< -o $@

main.o: src/main.cpp src/compare_execution_time.hpp
	g++ -O2 -m64 -c $< -o $@

buffers_management.o: src/buffers_management.cpp
	g++ -O2 -m64 -c $< -o $@

%.o: src/%.asm
	ml64 /Fo $@ /c $<

.PHONY: prog build_prog tests build_tests clean_prog clean_tests

build_prog: buffers_management.o $(ASM_OBJS) main.o
	g++ -m64 $^ -o prog.exe

build_tests: buffers_management.o $(ASM_OBJS) tests/tests.o
	g++ -m64 $^ -lgtest -lgtest_main -o tests/tests.exe

clean_prog:
	del *.o *.exe

clean_tests:
	del tests\*.o tests\*.exe