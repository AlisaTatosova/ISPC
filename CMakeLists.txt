cmake_minimum_required(VERSION 3.16)
project(NewtonFractal)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find ISPC compiler
find_program(ISPC_EXECUTABLE ispc)
if(NOT ISPC_EXECUTABLE)
    message(FATAL_ERROR "ISPC compiler not found")
endif()

# Download stb_image_write.h if not present
set(STB_URL "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h")
set(STB_FILE "${CMAKE_CURRENT_SOURCE_DIR}/stb_image_write.h")
if(NOT EXISTS ${STB_FILE})
    message(STATUS "Downloading stb_image_write.h...")
    file(DOWNLOAD ${STB_URL} ${STB_FILE} SHOW_PROGRESS)
endif()

set(ISPC_SRC "${CMAKE_CURRENT_SOURCE_DIR}/newton.ispc")
set(ISPC_OBJ "${CMAKE_CURRENT_BINARY_DIR}/newton.o")
set(ISPC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/newton.h")

add_custom_command(
    OUTPUT ${ISPC_OBJ} ${ISPC_HEADER}
    COMMAND ${ISPC_EXECUTABLE} ${ISPC_SRC} -o ${ISPC_OBJ} -h ${ISPC_HEADER} -O2
    DEPENDS ${ISPC_SRC}
    COMMENT "Compiling ISPC kernel"
)

add_executable(NewtonFractal main.cpp ${ISPC_OBJ} ${ISPC_HEADER})
target_include_directories(NewtonFractal PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
