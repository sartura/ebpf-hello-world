# ebpf-hello-world

This repo contains two simple example eBPF applications made to acoompany Sartura's eBPF programming [blog post](https://www.sartura.hr/blog/simple-ebpf-core-application/).

The first program is a hello world program that prints a message to `/sys/kernel/debug/tracing/trace_pipe`.
The second demonstrates BPF map use and execve system call tracing by storing the command name, UID and PID of the collected execve event.

## Building
For educational purposes the project doesn't use a makefile. Instead the blog post walks the user through manually building and running the examples.

First we need to make sure that the kernel we are using is configured to support BPF and that we have the required dependencies.

We will need a static version of libbpf:
```
$ git clone https://github.com/libbpf/libbpf && cd libbpf/src/
$ make BUILD_STATIC_ONLY=1 OBJDIR=../build/libbpf DESTDIR=../build INCLUDEDIR=
 LIBDIR= UAPIDIR= install
 ```
 
A short version of the build steps is provided here:
```
$ bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h
$ clang -g -O2 -target bpf -D__TARGET_ARCH_x86_64 -I . -c hello.bpf.c -o hello.bpf.o
$ bpftool gen skeleton hello.bpf.o > hello.skel.h
$ clang -g -O2 -Wall -I . -c hello.c -o hello.o
$ clang -Wall -O2 -g hello.o libbpf/build/libbpf.a -lelf -lz -o hello
$ sudo ./hello
```

For a detailed of the build process and commands used, read the accompanying [post](https://www.sartura.hr/blog/simple-ebpf-core-application/)
