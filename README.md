# Makefile与CMake

## Makefile

### Makefile举例

首先先定义3个cpp文件和1个头文件。

```c++
// main.cpp
#include<iostream>
#include "functions.h"
using namespace std;
int main(void) {
    printhello();

    cout << "This is main: "<<endl;
    cout << "The factorial of 5 is: "<< factorial(5) << endl;
    return 0;
}
```

```c++
// printhello.cpp
#include<iostream>
using namespace std;

void printhello(void) {
    cout<<"Hello Makefile!"<<endl;
}
```

```c++
// factorial.cpp
#include<iostream>
using namespace std;
int factorial(int n) {
    int res=1;
    for(int i=1;i<=n;i++){
        res*=i;
    }
    return res;
}
```

```c++
// functions.h
#ifndef _FUNCTIONS_H_
#define _FUNCTIONS_H_
int factorial(int n);
void printhello();
#endif
```

为了将三个cpp文件进行编译并链接，需要执行以下命令。

```bash
g++ main.cpp factorial.cpp printhello.cpp -o main
```

上诉方法，当源文件非常多时，编译需要很长时间。

```bash
g++ main.cpp -c
g++ factorial.cpp -c
g++ printhello.cpp -c
# -c 只能生成与.cpp文件名相对应的.o文件
# 想要生成指定名称的.o文件需要使用-o选项[output<filenames>]
```

**使用-c命令会生成.o文件，相当于只编译不链接。**

```bash
g++ *.o -o main
```

使用-o命令将所有.o文件进行链接生成可执行程序main。

使用-c和-o命令可以手动选择只编译修改后的文件。

当项目较大时，文件数量较多上诉手动输入过于复杂。因此我们可以将编译链接命令写入一个脚本文件中，即Makefile。

---

```makefile
# Version 1
# 生成的可执行程序(目标)：依赖的.cpp文件
# (tab)生成目标使用的命令
hello: main.cpp printhello.cpp factorial.cpp
	g++ -o hello main.cpp printhello.cpp factorial.cpp
```

```bash
hzj@node164:~/learn_makefile$ make
hzj@node164:~/learn_makefile$ ls
drwxrwxr-x  2 hzj hzj  4096 Aug 10 08:15 ./
drwxr-xr-x 22 hzj hzj  4096 Aug 10 08:07 ../
-rw-rw-r--  1 hzj hzj   144 Aug  9 11:05 factorial.cpp
-rw-rw-r--  1 hzj hzj    92 Aug  9 11:09 functions.h
-rwxrwxr-x  1 hzj hzj 13440 Aug 10 08:15 hello*
-rw-rw-r--  1 hzj hzj   198 Aug 10 08:15 main.cpp
-rw-rw-r--  1 hzj hzj   202 Aug 10 08:13 Makefile
-rw-rw-r--  1 hzj hzj   101 Aug  9 11:04 printhello.cpp
# 当hello对象比其依赖的cpp文件都要新时执行make命令不会编译
make: 'hello' is up to date.
# 当对main.cpp文件中内容进行修改后执行make命令
hzj@node164:~/learn_makefile$ make
g++ -o hello main.cpp printhello.cpp factorial.cpp
# 发现当一个文件修改后make命令会重新对所有cpp文件进行编译生成目标文件。
```

---

```makefile
# Version 2
# 定义c++所使用的编译器变量
CXX = g++
# 定义生成可执行程序(目标)
TARGET = hello
# 定义对象文件
OBJ = main.o printhello.o factorial.o

# 将目标文件所需的对象文件进行链接
# (tab)$(CXX) -o  $(TARGET) $(OBJ)
$(TARGET) : $(OBJ)
	$(CXX) -o  $(TARGET) $(OBJ)

# 根据cpp文件生成对应的对象文件
main.o: main.cpp
	$(CXX) -c main.cpp

printhello.o: printhello.cpp
	$(CXX) -c printhello.cpp

factorial.o: factorial.cpp
	$(CXX) -c factorial.cpp
```

```bash
hzj@node164:~/learn_makefile$ make
g++ -c main.cpp
g++ -c printhello.cpp
g++ -c factorial.cpp
g++ -o  hello main.o printhello.o factorial.o
hzj@node164:~/learn_makefile$ ll
total 56
drwxrwxr-x  2 hzj hzj  4096 Aug 10 08:30 ./
drwxr-xr-x 22 hzj hzj  4096 Aug 10 08:07 ../
-rw-rw-r--  1 hzj hzj   144 Aug  9 11:05 factorial.cpp
-rw-rw-r--  1 hzj hzj  2424 Aug 10 08:30 factorial.o
-rw-rw-r--  1 hzj hzj    92 Aug  9 11:09 functions.h
-rwxrwxr-x  1 hzj hzj 13440 Aug 10 08:30 hello*
-rw-rw-r--  1 hzj hzj   198 Aug 10 08:19 main.cpp
-rw-rw-r--  1 hzj hzj  3184 Aug 10 08:30 main.o
-rw-rw-r--  1 hzj hzj   712 Aug 10 08:30 Makefile
-rw-rw-r--  1 hzj hzj   101 Aug  9 11:04 printhello.cpp
-rw-rw-r--  1 hzj hzj  2792 Aug 10 08:30 printhello.o
# 这样当一个文件发生修改后之后对相应的cpp文件进行编译，可以节约编译时间。
```

---

```makefile
# Version3
CXX = g++
TARGET = hello
OBJ = main.o printhello.o factorial.o
# 编译选项 -W代表开启警告 all代表所有警告
CXXFLAGS = -c -Wall
# $@: 即:号前的目标文件		$^: 即:号后的所有依赖文件
$(TARGET): $(OBJ)
	$(CXX) -o $@ $^ 
# %.o通配符
# $^代表:后面所有的文件 $<代表:冒号后的第一个文件
%.o : %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
# .PHONY的作用是为了防止项目中有文件名为clean的文件而导致make clean失效
.PHONY: clean
# 定义make clean执行的shell指令
clean:
	rm *.o $(TARGET)
```

```bash
hzj@node164:~/learn_makefile$ make
g++ -c -Wall main.cpp -o main.o
g++ -c -Wall printhello.cpp -o printhello.o
g++ -c -Wall factorial.cpp -o factorial.o
g++ -o hello main.o printhello.o factorial.o 
hzj@node164:~/learn_makefile$ ls
factorial.cpp  factorial.o  functions.h  hello  main.cpp  main.o  Makefile  printhello.cpp  printhello.o
hzj@node164:~/learn_makefile$ make clean
rm *.o hello
hzj@node164:~/learn_makefile$ ls
factorial.cpp  functions.h  main.cpp  Makefile  printhello.cpp
```

---

```makefile
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
```



---

### Makefile函数调用语法



```makefile
# makefile函数调用原型：
# 函数调用以"$"开始，然后使用()/{}
# 函数名与参数列表之间以空格分割
$(<function> <arguments>)
${<function> <arguments>}
# 参数之间以","分割
#subst函数作用是将字符串“maktfilt中”的't'替换为'e'，其中函数名为subst ，参数为t,e,maktfilt
$(subst t,e,maktfilt) 
```

#### wildcard函数

wildcard函数是针对**通配符在函数或变量定义中展开无效情况下使用的**，用于获取匹配该模式下的**所有文件列表**，**<PATTERN...>参数若有多个则用空格分隔**。若没有找到指定的匹配模式则返回为空。

wildcard函数调用原型：

```makefile
$(wildcard <PATTERN...>)
#返回make工作下的所有.cpp以及.c文件
$(wildcard *.cpp *.c)
```

#### patsubst函数

patsubst函数返回被替换过后的字符串。patsubst函数判断<text>中字符串（若多个字符串以空格分隔）是否匹配<pattern>模式，若匹配则使用<replacement>替换<text>。<pattern>可以包括通配符%表示任意长度的字串。如果<replacement>中也包含%，则<replacement>中的这个%将是<pattern>中的那个%所代表的字符串。若字符串中含有%则可以用反斜杠\来转义，即\%来表示真实含义的%字符。

patsubst函数调用原型：

```makefile
$(patsubst  <pattern>,<replacement>,<text>)
# 把字符串"x.c.c bar.c"符合模式%.c的单词替换成%.o,返回"x.c.o bar.o"
$(patsubst %.c,%.o,x.c.c bar.c)
```

---

### 参考资料：

- [Makefile 20分钟入门，简简单单，展示如何使用Makefile管理和编译C++代码_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV188411L7d2/?spm_id_from=333.1007.top_right_bar_window_custom_collection.content.click&vd_source=7ce2cf74532cb657bcbfa607f6df3617)
- [【makefile笔记】patsubst和wildcard函数使用小结_wangqingchuan92的博客-CSDN博客](https://blog.csdn.net/wangqingchuan92/article/details/116452631)

---

## CMake

Makefile的配置与系统有非常强烈的关系（系统不同、编译器不同、文件路径不同）都会导致需要重新编写相应的Makefile文件。为了良好的跨平台特性CMake诞生了，其可以自动生成相应平台/编译器的Makefile文件。





