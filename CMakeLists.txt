cmake_minimum_required(VERSION 3.4.3)
project(LLHP)
set(CMAKE_MODULE_PATH
  "${CMAKE_SOURCE_DIR}/cmake"
  "${CMAKE_SOURCE_DIR}/cmake/Modules"
  ${CMAKE_MODULE_PATH}
  )
set(LLVM_DIR "${CMAKE_SOURCE_DIR}/cmake/Modules")
find_package(LLVM REQUIRED CONFIG)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

file(GLOB LLHP_SRC
    "src/*.cpp"
    "src/*.mm"
)

add_library(LLHP ${LLHP_SRC})

# Find the libraries that correspond to the LLVM components
# that we wish to use
llvm_map_components_to_libnames(llvm_libs support core irreader)

# Link against LLVM libraries
include_directories(include/)
target_link_libraries(LLHP ${llvm_libs})
