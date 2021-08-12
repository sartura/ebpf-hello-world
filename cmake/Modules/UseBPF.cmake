# SPDX-License-Identifier: MIT
#
# Copyright (c) 2021 Sartura Ltd.
#

find_program(BPFTOOL_EXECUTABLE NAMES bpftool DOC "path to the bpftool executable")
mark_as_advanced(BPFTOOL_EXECUTABLE)

find_package(Clang REQUIRED)
find_package(LIBBPF REQUIRED)

#
# BPF_TARGET (public macro)
# ------------------------------------------------------------
macro(BPF_TARGET Name Input Output OutputSkel)

    set(BPF_TARGET_PARAM_OPTIONS)
    set(BPF_TARGET_PARAM_ONE_VALUE_KEYWORDS
        COMPILE_FLAGS
        VMLINUX_FILE
        BPF_ARCH
        )
    set(BPF_TARGET_PARAM_MULTI_VALUE_KEYWORDS)

    cmake_parse_arguments(
        BPF_TARGET_ARG
        "${BPF_TARGET_PARAM_OPTIONS}"
        "${BPF_TARGET_PARAM_ONE_VALUE_KEYWORDS}"
        "${BPF_TARGET_MULTI_VALUE_KEYWORDS}"
        ${ARGN}
        )

    set(BPF_TARGET_usage "BPF_TARGET(<Name> <Input> <Output> <OutputSkel> [COMPILE_FLAGS <string>] [VMLINUX_FILE <string>] [BPF_ARCH <string>]")

    if(NOT "${BPF_TARGET_ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
        message(SEND_ERROR ${BPF_TARGET_usage})
    else()

        set(_bpf_INPUT "${Input}")
        set(_bpf_WORKING_DIR "${CMAKE_CURRENT_BINARY_DIR}")
        if(NOT IS_ABSOLUTE "${_bpf_INPUT}")
            set(_bpf_INPUT "${CMAKE_CURRENT_SOURCE_DIR}/${_bpf_INPUT}")
        endif()

        set(_bpf_OUTPUT "${Output}")
        if(NOT IS_ABSOLUTE ${_bpf_OUTPUT})
            set(_bpf_OUTPUT "${_bpf_WORKING_DIR}/${_bpf_OUTPUT}")
        endif()

        set(_bpf_OUTPUT_SKEL "${OutputSkel}")
        if(NOT IS_ABSOLUTE ${_bpf_OUTPUT_SKEL})
            set(_bpf_OUTPUT_SKEL "${_bpf_WORKING_DIR}/${_bpf_OUTPUT_SKEL}")
        endif()

        set(_bpf_VMLINUX "")
        if(NOT "${BPF_TARGET_ARG_VMLINUX_FILE}" STREQUAL "")
            set(_bpf_VMLINUX "${BPF_TARGET_ARG_VMLINUX_FILE}")
        endif()

        set(_bpf_ARCH "x86")
        if(NOT "${BPF_TARGET_ARG_BPF_ARCH}" STREQUAL "")
            set(_bpf_ARCH "${BPF_TARGET_ARG_BPF_ARCH}")
        endif()

        set(_bpf_EXE_OPTS "")
        if(NOT "${BPF_TARGET_ARG_COMPILE_FLAGS}" STREQUAL "")
            set(_bpf_EXE_OPTS "${BPF_TARGET_ARG_COMPILE_FLAGS}")
            separate_arguments(_bpf_EXE_OPTS)
        endif()
        list(APPEND _bpf_EXE_OPTS -g -O2)

        add_custom_command(OUTPUT ${_bpf_OUTPUT}
            COMMAND clang -target bpf -D__TARGET_ARCH_${_bpf_ARCH} ${_bpf_EXE_OPTS} -I${LIBBPF_INCLUDE_DIRS} -I${CMAKE_BINARY_DIR} -o ${_bpf_OUTPUT} -c ${_bpf_INPUT}
            VERBATIM
            DEPENDS ${_bpf_INPUT} ${_bpf_VMLINUX}
            COMMENT "[BPF][${Name}] Building program ... "
            WORKING_DIRECTORY ${_bpf_WORKING_DIR})

        add_custom_command(OUTPUT ${_bpf_OUTPUT_SKEL}
            COMMAND bpftool gen skeleton ${_bpf_OUTPUT} > ${_bpf_OUTPUT_SKEL}
            VERBATIM
            DEPENDS ${_bpf_OUTPUT}
            COMMENT "[BPF][${Name}] Building program skeleton ... "
            WORKING_DIRECTORY ${_bpf_WORKING_DIR})

        set(BPF_${Name}_DEFINED TRUE)
        set(BPF_${Name}_OUTPUT ${_bpf_OUTPUT})
        set(BPF_${Name}_OUTPUT_SKEL ${_bpf_OUTPUT_SKEL})
        set(BPF_${Name}_INPUT ${_bpf_INPUT})
        set(BPF_${Name}_COMPILE_FLAGS ${_bpf_EXE_OPTS})

        unset(_bpf_EXE_OPTS)
        unset(_bpf_INPUT)
        unset(_bpf_OUTPUT)
        unset(_bpf_OUTPUT_SKEL)
        unset(_bpf_WORKING_DIR)

        set_source_files_properties(${BPF_${Name}_OUTPUT}
            PROPERTIES OBJECT_DEPENDS ${BPF_${Name}_OUTPUT_SKEL})
    endif()
endmacro()
# ------------------------------------------------------------

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(BPF REQUIRED_VARS BPFTOOL_EXECUTABLE VERSION_VAR BPF_VERSION)
