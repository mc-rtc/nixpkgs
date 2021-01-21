cmake_minimum_required(VERSION 3.1)

project(MyProject LANGUAGES CXX VERSION 1.0.0)

find_package(mc_rtc REQUIRED)

if(mc_rtc_VERSION VERSION_GREATER_EQUAL 2.0.0)
  set(CMAKE_CXX_STANDARD 17)
endif()

add_executable(main main.cpp)
target_link_libraries(main mc_rtc::mc_control)
