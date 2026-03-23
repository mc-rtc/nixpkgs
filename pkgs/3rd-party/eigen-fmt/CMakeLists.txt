cmake_minimum_required(VERSION 3.12)
project(eigen-fmt LANGUAGES CXX)

# Create the header-only target
add_library(eigen-fmt INTERFACE)
add_library(eigen-fmt::eigen-fmt ALIAS eigen-fmt)
target_include_directories(eigen-fmt INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# Install the header
install(
    FILES include/eigen-fmt/eigen-fmt/fmt.h
    DESTINATION include/eigen-fmt
)

# Export the target for find_package
install(TARGETS eigen-fmt
    EXPORT eigen-fmtTargets
)

install(EXPORT eigen-fmtTargets
    FILE eigen-fmtTargets.cmake
    NAMESPACE eigen-fmt::
    DESTINATION lib/cmake/eigen-fmt
)

# Generate and install the config file
include(CMakePackageConfigHelpers)
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/eigen-fmtConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/eigen-fmtConfig.cmake
    INSTALL_DESTINATION lib/cmake/eigen-fmt
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/eigen-fmtConfig.cmake
    DESTINATION lib/cmake/eigen-fmt
)
