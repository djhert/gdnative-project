CMAKE_MINIMUM_REQUIRED(VERSION 3.15)
# Set name of project to current directory name
GET_FILENAME_COMPONENT(ProjectId ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)
GET_FILENAME_COMPONENT(ProjectId ${ProjectId} NAME)
STRING(REPLACE " " "_" ProjectId ${ProjectId})
PROJECT(${ProjectId} LANGUAGES CXX)


SET(VERSIONS_DIR ${PROJECT_BINARY_DIR}/versions)

# reset and include the version.txt
FILE(REMOVE_RECURSE ${VERSIONS_DIR})
INCLUDE(${PROJECT_SOURCE_DIR}/version.txt OPTIONAL)

# Default to "Debug", use -DCMAKE_BUILD_TYPE=Release for release build
IF(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE Debug)
ENDIF()
SET(CMAKE_CXX_STANDARD 17)

# Variables used later in branches
SET(C_FLAGS )
SET(L_FLAGS )

# Get Bits of OS
SET(BITS 32)
IF(CMAKE_SIZEOF_VOID_P EQUAL 8)
  SET(BITS 64)
ENDIF()

# Get system name
STRING(TOLOWER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME)
# Get Build type
STRING(TOLOWER ${CMAKE_BUILD_TYPE} BUILD_TYPE)

# Set output directory
SET(OUTPATH "${PROJECT_SOURCE_DIR}/../lib/${SYSTEM_NAME}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${OUTPATH}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPATH}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPATH}")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${OUTPATH}")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${OUTPATH}")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUTPATH}")
SET(CMAKE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

#Check compiler, and set flags appropriately
IF("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")
  SET(C_FLAGS "${C_FLAGS} /DWIN32 /D_WIN32 /D_WINDOWS /W3 /GR /D_CRT_SECURE_NO_WARNINGS /DNOMINMAX /EHsc")
  SET(L_FLAGS "${L_FLAGS} /WX /INCREMENTAL:NO")
  IF("${CMAKE_BUILD_TYPE}" MATCHES Release)
    SET(C_FLAGS "${C_FLAGS} /02 /DNDEBUG /MD")
  ELSE()
    SET(C_FLAGS "${C_FLAGS} /MDd /D_DEBUG")
  ENDIF()
ELSE()
  SET(C_FLAGS "${C_FLAGS} -fPIC -Wwrite-strings")
  IF("${CMAKE_BUILD_TYPE}" MATCHES Release)
    SET(C_FLAGS "${C_FLAGS} -O3 -DNDEBUG")
  ELSE()
    SET(C_FLAGS "${C_FLAGS} -g -D_DEBUG")
  ENDIF()
ENDIF()

# Find all source files in source dir
FILE(GLOB_RECURSE SOURCES ${PROJECT_SOURCE_DIR}/src/*.c**)
FILE(GLOB_RECURSE HEADERS ${PROJECT_SOURCE_DIR}/src/*.h**)

# Define library
ADD_LIBRARY(${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS})

# Set target features
TARGET_COMPILE_FEATURES(${PROJECT_NAME} PUBLIC cxx_std_17)
SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES PREFIX "lib")
IF(ANDROID)
	SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "${PROJECT_NAME}.${ANDROID_ABI}")
ELSE()
  SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "${PROJECT_NAME}.${BITS}")
ENDIF()

# Include godot-cpp and other needed stuff
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME}
  PUBLIC
  ${PROJECT_SOURCE_DIR}/include
  ${PROJECT_SOURCE_DIR}/include/godot-cpp/include
  ${PROJECT_SOURCE_DIR}/include/godot-cpp/include/core
  ${PROJECT_SOURCE_DIR}/include/godot-cpp/include/gen
  ${VERSIONS_DIR}
  ${PROJECT_SOURCE_DIR}/src
)

# Include godot_headers
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME}
  SYSTEM PUBLIC ${PROJECT_SOURCE_DIR}/include/godot-cpp/godot_headers
)

# Set compile flags
SET_PROPERTY(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY COMPILE_FLAGS ${C_FLAGS})
SET_PROPERTY(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY LINK_FLAGS ${L_FLAGS})

# Include godot-cpp
MESSAGE(STATUS "Include: " godot-cpp)
ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/include/godot-cpp ${PROJECT_BINARY_DIR}/godot-cpp)
# Since we should have found godot-cpp, include the project now
ADD_DEPENDENCIES(${PROJECT_NAME} godot-cpp)
# Include libgodot-cpp
TARGET_LINK_LIBRARIES(${PROJECT_NAME} godot-cpp)

# Define current folder for reference
SET(SourceDir ${PROJECT_SOURCE_DIR})

## Macro to search subdirectories and return list
MACRO(SUBDIRS result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
      LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

# Check includes for subdirs to include
SUBDIRS(subdirs ${PROJECT_SOURCE_DIR}/include)
FOREACH(subdir ${subdirs})
  IF(${subdir} STREQUAL "godot-cpp")
    CONTINUE()
  ENDIF()
  SET(binarydir ${PROJECT_BINARY_DIR}/${subdir})
  SET(fullsubdir ${PROJECT_SOURCE_DIR}/include/${subdir})
  IF(EXISTS ${fullsubdir}/CMakeLists.txt)
    MESSAGE(STATUS "Include: " ${subdir})
    ADD_SUBDIRECTORY(${fullsubdir} ${binarydir})
  ENDIF()
ENDFOREACH()

# Check addon subdirs for stuff
GET_FILENAME_COMPONENT(AddonDir ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)
SET(AddonDir ${AddonDir}/addons)
SUBDIRS(subdirs ${AddonDir})
FOREACH(subdir ${subdirs})
  SET(binarydir ${PROJECT_BINARY_DIR}/${subdir})
  SET(fullsubdir ${AddonDir}/${subdir}/source)
  IF(EXISTS ${fullsubdir}/CMakeLists.txt)
    MESSAGE(STATUS "Module: " ${subdir})
    ADD_SUBDIRECTORY(${fullsubdir} ${binarydir})
  ENDIF()
ENDFOREACH()

# Now that everything is setup, let's finalize versioning
MACRO(cat OUT IN)
  FILE(READ ${IN} CONTENTS)
  FILE(APPEND ${OUT} "${CONTENTS}")
ENDMACRO()

FILE(GLOB VERS ${VERSIONS_DIR}/version-*.hpp)
FOREACH(ver ${VERS})
  cat(${VERSIONS_DIR}/version.hpp ${ver})
ENDFOREACH()
