#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "hip-lang::amdhip64" for configuration "Release"
set_property(TARGET hip-lang::amdhip64 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hip-lang::amdhip64 PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/x86_64-linux-gnu/libamdhip64.so.5.0.13601-"
  IMPORTED_SONAME_RELEASE "libamdhip64.so.5"
  )

list(APPEND _IMPORT_CHECK_TARGETS hip-lang::amdhip64 )
list(APPEND _IMPORT_CHECK_FILES_FOR_hip-lang::amdhip64 "${_IMPORT_PREFIX}/lib/x86_64-linux-gnu/libamdhip64.so.5.0.13601-" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
