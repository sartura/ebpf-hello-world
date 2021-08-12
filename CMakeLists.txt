cmake_minimum_required(VERSION 3.5)
project(ebpf-core-sample)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")

find_package(LIBBPF REQUIRED)
include(UseBPF)

include_directories(${LIBBPF_INCLUDE_DIRS})
include_directories(${CMAKE_BINARY_DIR})

set(BPF_ARCH "" CACHE STRING "Architecture of eBPF programs")
option(INSTALL_VMLINUX "Enable installation of the vmlinux header" ON)

configure_file(${CMAKE_SOURCE_DIR}/include/vmlinux-${BPF_ARCH}.h
               ${CMAKE_BINARY_DIR}/vmlinux.h
               COPYONLY)
if(INSTALL_VMLINUX)
    install(FILES "${CMAKE_BINARY_DIR}/vmlinux.h" DESTINATION include)
endif()

#
# BPF targets
#
BPF_TARGET(hello-bpf src/hello.bpf.c
    ${CMAKE_BINARY_DIR}/hello.bpf.o
    ${CMAKE_BINARY_DIR}/hello.skel.h
    BPF_ARCH ${BPF_ARCH}
    VMLINUX_FILE ${CMAKE_BINARY_DIR}/vmlinux.h)
install(FILES "${CMAKE_BINARY_DIR}/hello.bpf.o" DESTINATION share)

BPF_TARGET(maps-bpf src/maps.bpf.c
    ${CMAKE_BINARY_DIR}/maps.bpf.o
    ${CMAKE_BINARY_DIR}/maps.skel.h
    BPF_ARCH ${BPF_ARCH}
    VMLINUX_FILE ${CMAKE_BINARY_DIR}/vmlinux.h)
install(FILES "${CMAKE_BINARY_DIR}/maps.bpf.o" DESTINATION share)

#
# BPF loader programs, with included BPF bytecode
#
add_executable(hello src/hello.c ${BPF_hello-bpf_OUTPUT_SKEL})
target_link_libraries(hello ${LIBBPF_LIBRARIES})
install(TARGETS hello DESTINATION bin)

add_executable(maps src/maps.c ${BPF_maps-bpf_OUTPUT_SKEL})
target_link_libraries(maps ${LIBBPF_LIBRARIES})
install(TARGETS maps DESTINATION bin)
