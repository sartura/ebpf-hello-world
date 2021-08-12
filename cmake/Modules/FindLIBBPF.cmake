find_package(PkgConfig)
pkg_check_modules(PC_LIBBPF libbpf)

find_path(LIBBPF_INCLUDE_DIR bpf.h
    HINTS ${PC_LIBBPF_INCLUDEDIR} ${PC_LIBBPF_INCLUDE_DIRS}
    PATH_SUFFIXES bpf)

find_library(LIBBPF_LIBRARY NAMES bpf
    HINTS ${PC_LIBBPF_LIBDIR} ${PC_LIBBPF_LIBRARY_DIRS})

set(LIBBPF_LIBRARIES ${LIBBPF_LIBRARY})
set(LIBBPF_INCLUDE_DIRS ${LIBBPF_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(LIBBPF DEFAULT_MSG LIBBPF_LIBRARY LIBBPF_INCLUDE_DIR)

mark_as_advanced(LIBBPF_INCLUDE_DIR LIBBPF_LIBRARY)