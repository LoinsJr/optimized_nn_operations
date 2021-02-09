ASM_SRCS = $(wildcard src/*.asm)
ASM_OBJS = $(patsubst src/%.asm, obj/%.o, $(ASM_SRCS))

prog: prog.exe
	prog.exe

tests: tests.exe
	tests.exe

tests.exe: obj/buffers_management.o $(ASM_OBJS) obj/tests.o
	g++ -m64 $^ -lgtest -lgtest_main -o $@

prog.exe: obj/buffers_management.o $(ASM_OBJS) obj/main.o
	g++ -m64 $^ -o $@

obj/tests.o: tests/tests.cpp
	g++ -O2 -m64 -c $< -o $@

obj/main.o: src/main.cpp src/compare_execution_time.hpp
	g++ -O2 -m64 -c $< -o $@

obj/buffers_management.o: src/buffers_management.cpp
	g++ -O2 -m64 -c $< -o $@

obj/%.o: src/%.asm
	ml64 /Fo $@ /c $<

.PHONY: prog build_prog tests build_tests clean

build_prog: obj/buffers_management.o $(ASM_OBJS) obj/main.o
	g++ -m64 $^ -o prog.exe

build_tests: obj/buffers_management.o $(ASM_OBJS) obj/tests.o
	g++ -m64 $^ -lgtest -lgtest_main -o tests/tests.exe

clean:
	del obj\*.o *.exe