# # Version 1

# # 生成的可执行程序(目标)：依赖的.cpp文件
# # (tab)生成目标使用的命令
# hello: main.cpp printhello.cpp factorial.cpp
# 	g++ -o hello main.cpp printhello.cpp factorial.cpp

# # Version 2
# # 定义c++所使用的编译器变量
# CXX = g++
# # 定义生成可执行程序(目标)
# TARGET = hello
# # 定义对象文件
# OBJ = main.o printhello.o factorial.o

# # 将目标文件所需的对象文件进行链接
# # (tab)$(CXX) -o  $(TARGET) $(OBJ)
# $(TARGET) : $(OBJ)
# 	$(CXX) -o  $(TARGET) $(OBJ)

# # 根据cpp文件生成对应的对象文件
# main.o: main.cpp
# 	$(CXX) -c main.cpp

# printhello.o: printhello.cpp
# 	$(CXX) -c printhello.cpp

# factorial.o: factorial.cpp
# 	$(CXX) -c factorial.cpp

# # Version3
# CXX = g++
# TARGET = hello
# OBJ = main.o printhello.o factorial.o
# # 编译选项 -W代表开启警告 all代表所有警告
# CXXFLAGS = -c -Wall
# # $@: 即:号前的目标文件		$^: 即:号后的所有依赖文件
# $(TARGET): $(OBJ)
# 	$(CXX) -o $@ $^ 
# # %.o通配符
# # $^代表:后面所有的文件 $<代表:冒号后的第一个文件
# %.o : %.cpp
# 	$(CXX) $(CXXFLAGS) $< -o $@
# # .PHONY的作用是为了防止项目中有文件名为clean的文件而导致make clean失效
# .PHONY: clean
# # 定义make clean执行的shell指令
# clean:
# 	rm *.o $(TARGET)

# Version 4
CXX = g++
TARGET = hello
# wildcard是一个函数
# 当定义变量或函数引用时通配符会失效，因此必须用wildcard函数使其有效
SRC = $(wildcard *.cpp)
# patsubst函数返回被替换过后的字符串
OBJ = $(patsubst %.cpp, %.o , $(SRC))

CXXFLAGS = -c -Wall

$(TARGET): $(OBJ)
	$(CXX) -o $@ $^
# 注意，这里只能使用%.o: %.cpp
# SRC和OBJ的替换还没有发生
%.o: %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
.PHONY: clean
clean:
	rm *.o $(TARGET)