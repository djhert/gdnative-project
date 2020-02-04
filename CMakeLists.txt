cmake_minimum_required(VERSION 3.15)
# Set name of project to current directory name
get_filename_component(ProjectId ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" ProjectId ${ProjectId})
project(${ProjectId} LANGUAGES CXX)

include(ExternalProject)

# Set version number
set (_VERSION_MAJOR 0)
set (_VERSION_MINOR 1)
set (_VERSION_REVISION 0)
configure_file (
  "${PROJECT_SOURCE_DIR}/source/version.hpp.in"
  "${PROJECT_BINARY_DIR}/gen/version.hpp"
)

# Default to "Release", use -DCMAKE_BUILD_TYPE=Debug for debug
if(NOT CMAKE_BUILD_TYPE) 
    set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_CXX_STANDARD 17)

# Variables used later in branches
set(C_FLAGS )
set(L_FLAGS )

# godot-cpp prefix and suffix for different platforms
set(GODOT_PREFIX )
set(GODOT_SUFFIX )

# Get Bits of OS
set(BITS 32)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(BITS 64)
endif()

# Get system name
string(TOLOWER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME)
# Get Build type
string(TOLOWER ${CMAKE_BUILD_TYPE} BUILD_TYPE)

# Set output directory
set(OUTPATH "${PROJECT_SOURCE_DIR}/project/lib/${SYSTEM_NAME}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${OUTPATH}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPATH}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPATH}")
set(CMAKE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

#Check compiler, and set flags appropriately
if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")
  # For some reason, windows builds it as "godot-cpp" instead of "libgodot-cpp"
  set(GODOT_PREFIX "godot-cpp")
  set(GODOT_SUFFIX "lib")
  set(C_FLAGS "${C_FLAGS} /DWIN32 /D_WIN32 /D_WINDOWS /W3 /GR /D_CRT_SECURE_NO_WARNINGS /EHsc")
  set(L_FLAGS "${L_FLAGS} /WX /INCREMENTAL:NO")
  if("${CMAKE_BUILD_TYPE}" MATCHES Release)
    set(C_FLAGS "${C_FLAGS} /02 /DNDEBUG /MD")
  else() 
    set(C_FLAGS "${C_FLAGS} /MDd /D_DEBUG")
  endif()
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "(GNU|Clang)")
  # Manually define since windows names differently
  set(GODOT_PREFIX "libgodot-cpp")
  set(GODOT_SUFFIX "a")
  set(C_FLAGS "${C_FLAGS} -fPIC -Wwrite-strings")
  if("${CMAKE_BUILD_TYPE}" MATCHES Release)
    set(C_FLAGS "${C_FLAGS} -O3 -DNDEBUG")
  else() 
    set(C_FLAGS "${C_FLAGS} -g -D_DEBUG")
  endif()
endif()

# Setup external godot-cpp project for tracking
ExternalProject_Add(libgodot-cpp
  SOURCE_DIR ${PROJECT_SOURCE_DIR}/include/godot-cpp
  GIT_REPOSITORY https://github.com/GodotNativeTools/godot-cpp
  GIT_TAG 3.2
  INSTALL_COMMAND ""
  UPDATE_COMMAND ""
  BUILD_BYPRODUCTS ${PROJECT_SOURCE_DIR}/include/godot-cpp/bin/${GODOT_PREFIX}.${SYSTEM_NAME}.${BUILD_TYPE}.${BITS}.${GODOT_SUFFIX}
  STAMP_DIR ${PROJECT_BINARY_DIR}/godot-cpp-stamp
  BINARY_DIR ${PROJECT_BINARY_DIR}/godot-cpp-build
)
add_library(godot-cpp STATIC IMPORTED)
set_property(TARGET godot-cpp PROPERTY IMPORTED_LOCATION ${PROJECT_SOURCE_DIR}/include/godot-cpp/bin/${GODOT_PREFIX}.${SYSTEM_NAME}.${BUILD_TYPE}.${BITS}.${GODOT_SUFFIX})

# include directories
include_directories(${PROJECT_SOURCE_DIR}/include/source,
  ${PROJECT_SOURCE_DIR}/include/source/include)

# Find all source files in source dir
file(GLOB_RECURSE SOURCES ${PROJECT_SOURCE_DIR}/source/*.c**)
file(GLOB_RECURSE HEADERS ${PROJECT_SOURCE_DIR}/source/*.h**)

# Define library
add_library(${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS})
add_dependencies(${PROJECT_NAME} libgodot-cpp)

# Set target features
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "lib${PROJECT_NAME}.${BITS}")

# Include godot-cpp and other needed stuff
target_include_directories(${PROJECT_NAME}
  PUBLIC
  ${PROJECT_SOURCE_DIR}/include
  ${PROJECT_SOURCE_DIR}/source/include
  ${PROJECT_SOURCE_DIR}/include/godot-cpp/include
  ${PROJECT_SOURCE_DIR}/include/godot-cpp/include/core
  ${PROJECT_SOURCE_DIR}/include/godot-cpp/include/gen
  ${PROJECT_SOURCE_DIR}/build/gen
)

# Include godot_headers and ignore any warnings
target_include_directories(${PROJECT_NAME}
  SYSTEM PUBLIC ${PROJECT_SOURCE_DIR}/include/godot-cpp/godot_headers
)

# Set compile flags
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY COMPILE_FLAGS ${C_FLAGS})
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY LINK_FLAGS ${L_FLAGS})

# Include libgodot-cpp
target_link_libraries(${PROJECT_NAME} godot-cpp)