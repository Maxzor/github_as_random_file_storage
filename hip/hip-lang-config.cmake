# Copyright (C) 2021 Kitware, Inc. All Rights Reserved.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was hip-lang-config.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

# Use original install prefix when loaded through a "/usr move"
# cross-prefix symbolic link such as /lib -> /usr/lib.
get_filename_component(_realCurr "${CMAKE_CURRENT_LIST_DIR}" REALPATH)
get_filename_component(_realOrig "/usr/lib/cmake/hip-lang" REALPATH)
if(_realCurr STREQUAL _realOrig)
  set(PACKAGE_PREFIX_DIR "/usr")
endif()
unset(_realOrig)
unset(_realCurr)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################
include(CMakeFindDependencyMacro OPTIONAL RESULT_VARIABLE _CMakeFindDependencyMacro_FOUND)
if (NOT _CMakeFindDependencyMacro_FOUND)
  macro(find_dependency dep)
    if (NOT ${dep}_FOUND)
      set(cmake_fd_version)
      if (${ARGC} GREATER 1)
        set(cmake_fd_version ${ARGV1})
      endif()
      set(cmake_fd_exact_arg)
      if(${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION_EXACT)
        set(cmake_fd_exact_arg EXACT)
      endif()
      set(cmake_fd_quiet_arg)
      if(${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
        set(cmake_fd_quiet_arg QUIET)
      endif()
      set(cmake_fd_required_arg)
      if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
        set(cmake_fd_required_arg REQUIRED)
      endif()
      find_package(${dep} ${cmake_fd_version}
          ${cmake_fd_exact_arg}
          ${cmake_fd_quiet_arg}
          ${cmake_fd_required_arg}
      )
      string(TOUPPER ${dep} cmake_dep_upper)
      if (NOT ${dep}_FOUND AND NOT ${cmake_dep_upper}_FOUND)
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "${CMAKE_FIND_PACKAGE_NAME} could not be found because dependency ${dep} could not be found.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND False)
        return()
      endif()
      set(cmake_fd_version)
      set(cmake_fd_required_arg)
      set(cmake_fd_quiet_arg)
      set(cmake_fd_exact_arg)
    endif()
  endmacro()
endif()

set(HIP_COMPILER "clang")
set(HIP_RUNTIME "rocclr")

find_dependency(AMDDeviceLibs)
find_dependency(amd_comgr)

include( "${CMAKE_CURRENT_LIST_DIR}/hip-lang-targets.cmake" )

#get_filename_component cannot resolve the symlinks if called from /opt/rocm/lib/hip
#and do three level up again
get_filename_component(_DIR "${CMAKE_CURRENT_LIST_DIR}" REALPATH)
get_filename_component(_IMPORT_PREFIX "${_DIR}/../../../" REALPATH)


#need _IMPORT_PREFIX to be set
file(GLOB HIP_CLANG_INCLUDE_SEARCH_PATHS "${_IMPORT_PREFIX}/../llvm/lib/clang/*/include")
find_path(HIP_CLANG_INCLUDE_PATH __clang_cuda_math.h
    HINTS ${HIP_CLANG_INCLUDE_SEARCH_PATHS}
    NO_DEFAULT_PATH)
get_filename_component(HIP_CLANG_INCLUDE_PATH "${HIP_CLANG_INCLUDE_PATH}" DIRECTORY)

#If HIP isnot installed under ROCm, need this to find HSA assuming HSA is under ROCm
if( DEFINED ENV{ROCM_PATH} )
  set(ROCM_PATH "$ENV{ROCM_PATH}")
endif()

#if HSA is not under ROCm then provide CMAKE_PREFIX_PATH=<HSA_PATH>
find_path(HSA_HEADER hsa/hsa.h
  PATHS
    "${_IMPORT_PREFIX}/../include"
    "${ROCM_PATH}/include"
    /opt/rocm/include
)

if (HSA_HEADER-NOTFOUND)
  message (FATAL_ERROR "HSA header not found! ROCM_PATH environment not set")
endif()

file(GLOB HIP_CLANGRT_LIB_SEARCH_PATHS "${CMAKE_HIP_COMPILER}/../lib/clang/*/lib/*")
find_library(CLANGRT_BUILTINS
    NAMES
      clang_rt.builtins
      clang_rt.builtins-x86_64
    PATHS
      ${HIP_CLANGRT_LIB_SEARCH_PATHS}
      ${HIP_CLANG_INCLUDE_PATH}/../lib/linux)

set_target_properties(hip-lang::device PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "$<$<COMPILE_LANGUAGE:HIP>:${_IMPORT_PREFIX}/../include;${HIP_CLANG_INCLUDE_PATH}>"
  INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "$<$<COMPILE_LANGUAGE:HIP>:${_IMPORT_PREFIX}/../include;${HIP_CLANG_INCLUDE_PATH}>"
)

set_target_properties(hip-lang::amdhip64 PROPERTIES
  INTERFACE_COMPILE_DEFINITIONS "$<$<COMPILE_LANGUAGE:HIP>:__HIP_ROCclr__=1>"
  INTERFACE_INCLUDE_DIRECTORIES "$<$<COMPILE_LANGUAGE:HIP>:${_IMPORT_PREFIX}/include;${HSA_HEADER}>"
  INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "$<$<COMPILE_LANGUAGE:HIP>:${_IMPORT_PREFIX}/include;${HSA_HEADER}>"
)
set_target_properties(hip-lang::device PROPERTIES
  INTERFACE_COMPILE_DEFINITIONS "$<$<COMPILE_LANGUAGE:HIP>:__HIP_ROCclr__=1>"
)

set_property(TARGET hip-lang::device APPEND PROPERTY
  INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:HIP>:SHELL:-mllvm;-amdgpu-early-inline-all=true;-mllvm;-amdgpu-function-calls=false>"
)

if (NOT EXISTS "${AMD_DEVICE_LIBS_PREFIX}/amdgcn/bitcode")
  set_property(TARGET hip-lang::device APPEND PROPERTY
    INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:HIP>:--hip-device-lib-path=${AMD_DEVICE_LIBS_PREFIX}/lib>"
  )
endif()

set_property(TARGET hip-lang::device APPEND PROPERTY
  INTERFACE_LINK_OPTIONS "$<$<LINK_LANGUAGE:HIP>:--hip-link>"
)

# Add support for __fp16 and _Float16, explicitly link with compiler-rt
if(CLANGRT_BUILTINS-NOTFOUND)
    message(FATAL_ERROR "clangrt builtins lib not found")
else()
  set_property(TARGET hip-lang::device APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "$<$<LINK_LANGUAGE:HIP>:${CLANGRT_BUILTINS}>"
  )
endif()

# Approved by CMake to use this name. This is used so that HIP can
# change the name of the target and not require any modifications in CMake
set(_CMAKE_HIP_DEVICE_RUNTIME_TARGET "hip-lang::device")
