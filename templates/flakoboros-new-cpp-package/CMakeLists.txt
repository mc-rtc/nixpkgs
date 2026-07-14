#
# Copyright 2026 CNRS-UM LIRMM, CNRS-AIST JRL
#

cmake_minimum_required(VERSION 3.22)
include(cmake/get-jrl-cmakemodules.cmake)

project(
    cpp-template
    VERSION 1.0.0 
    DESCRIPTION ""
    HOMEPAGE_URL "https://github.com/${PROJECT_NAME}"
    LANGUAGES CXX
)

# Configure default binary and install directories, build type, etc.
jrl_configure_defaults()

# -------
# OPTIONS
# -------
jrl_option(BUILD_TESTING "Whether to build unit tests" ON)
jrl_print_options_summary()

# ------------
# DEPENDENCIES
# Use:
# - jrl_find_package(<package> [REQUIRED] [QUIET]) for dependencies that are exported by this project
# - find_package(<package> [REQUIRED] [QUIET]) for dependencies that are internally used this project
# ------------

jrl_find_package(Eigen3 QUIET EXPECTED_TARGETS Eigen3::Eigen)

if(BUILD_TESTING)
    enable_testing()
    find_package(Catch2 3 QUIET)
    if(NOT Catch2_FOUND)
        include(FetchContent)
        FetchContent_Declare(
            Catch2
            GIT_REPOSITORY https://github.com/catchorg/Catch2.git
            GIT_TAG v3.6.0
        )
        FetchContent_MakeAvailable(Catch2)
    endif()
endif()

# ------------
# BUILD 
# ------------
add_library(${PROJECT_NAME} SHARED src/cpp-template.cpp)
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)
target_link_libraries(
${PROJECT_NAME}
PUBLIC Eigen3::Eigen
)
target_include_directories(${PROJECT_NAME} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)
jrl_target_headers(${PROJECT_NAME} PUBLIC HEADERS include/${PROJECT_NAME}/cpp-template.h BASE_DIRS include)
jrl_add_export_component(NAME ${PROJECT_NAME} TARGETS ${PROJECT_NAME})

# --------
# Tests
# --------
if(BUILD_TESTING)
    add_executable(test-${PROJECT_NAME} test/test-${PROJECT_NAME}.cpp)
    target_link_libraries(
        test-${PROJECT_NAME}
        PUBLIC ${PROJECT_NAME} Catch2::Catch2WithMain
    )
    add_test(NAME test-${PROJECT_NAME} COMMAND test-${PROJECT_NAME})
    # # Set LD_LIBRARY_PATH for the test (for Nix)
    # set_tests_properties(
    #     test_path
    #     PROPERTIES
    #         ENVIRONMENT
    #             "LD_LIBRARY_PATH=$<TARGET_FILE_DIR:mc_rtc_ros_compat>:$ENV{LD_LIBRARY_PATH}"
    # )
endif()

# Export the package files (headers, targets, config files, etc.)
jrl_export_package()

# Print summaries
jrl_print_dependencies_summary()
