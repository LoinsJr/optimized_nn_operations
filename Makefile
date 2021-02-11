ASM_SRCS = $(wildcard src/*.asm)
ASM_OBJS = $(patsubst src/%.asm, obj/%.o, $(ASM_SRCS))
ASMC = ml64
build_prog: obj/buffers_management.o $(ASM_OBJS) obj/main.o
	g++ -m64 $^ -o prog.exe

build_tests: obj/buffers_management.o $(ASM_OBJS) obj/tests.o
	g++ -m64 $^ -Llib -lgtest -lgtest_main -o tests.exe

obj/tests.o: tests/tests.cpp
	g++ -O2 -m64 -Iinclude -c $< -o $@

obj/%.o: src/%.cpp
	g++ -O2 -m64 -Iinclude -c $< -o $@

obj/%.o: src/%.asm
	$(ASMC) /Fo $@ /c $<

.PHONY: prog build_prog tests build_tests clean

clean:
	del obj\*.o *.exe