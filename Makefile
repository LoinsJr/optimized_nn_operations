ASM_SRCS = $(wildcard src/*.asm)
ASM_OBJS = $(patsubst src/%.asm, obj/%.o, $(ASM_SRCS))
TESTS_SRCS = $(wildcard tests/*.cpp)
TESTS_OBJS = $(patsubst tests/%.cpp, obj/%.o, $(TESTS_SRCS))
CXX = g++
ASMC = ml64

build_prog: obj link_prog

link_prog: obj/buffers_management.o $(ASM_OBJS) obj/main.o
	$(CXX) -m64 $^ -o prog.exe

build_tests: obj link_tests

link_tests: obj/buffers_management.o $(ASM_OBJS) $(TESTS_OBJS)
	$(CXX) -m64 $^ -Llib -lgtest -lgtest_main -o tests.exe

obj/%.o: src/%.cpp
	$(CXX) -O2 -m64 -Iinclude -c $< -o $@

obj/%.o: tests/%.cpp
	$(CXX) -O2 -m64 -Iinclude -c $< -o $@

obj/%.o: src/%.asm
	$(ASMC) /Fo $@ /c $<

obj:
	mkdir obj

.PHONY: prog build_prog tests build_tests clean

clean:
	del obj\*.o *.exe