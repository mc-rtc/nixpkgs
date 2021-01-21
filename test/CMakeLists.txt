cmake_minimum_required(VERSION 3.1)

project(MyProject LANGUAGES CXX VERSION 1.0.0)

find_package(mc_rtc REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main mc_rtc::mc_control)
