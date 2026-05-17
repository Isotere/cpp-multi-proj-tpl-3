# Helpers for common project target shapes.

include(GoogleTest)

function(project_add_library target)
    cmake_parse_arguments(ARG "INCLUDE_CURRENT_DIR" "" "SOURCES;LIBRARIES" ${ARGN})

    add_library(${target})
    target_sources(${target} PRIVATE ${ARG_SOURCES})
    target_compile_features(${target} PUBLIC cxx_std_23)
    project_apply_warnings(${target})

    if(ARG_INCLUDE_CURRENT_DIR)
        target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    if(ARG_LIBRARIES)
        target_link_libraries(${target} PUBLIC ${ARG_LIBRARIES})
    endif()
endfunction()

function(project_add_executable target)
    cmake_parse_arguments(ARG "" "" "SOURCES;LIBRARIES" ${ARGN})

    add_executable(${target} ${ARG_SOURCES})
    target_compile_features(${target} PRIVATE cxx_std_23)
    project_apply_warnings(${target})

    if(ARG_LIBRARIES)
        target_link_libraries(${target} PRIVATE ${ARG_LIBRARIES})
    endif()
endfunction()

function(project_add_gtest target)
    cmake_parse_arguments(ARG "" "" "SOURCES;LIBRARIES" ${ARGN})

    add_executable(${target} ${ARG_SOURCES})
    target_compile_features(${target} PRIVATE cxx_std_23)
    target_link_libraries(${target} PRIVATE ${ARG_LIBRARIES} GTest::gtest_main)
    project_apply_warnings(${target})
    gtest_discover_tests(${target})
endfunction()

function(project_add_benchmark target)
    if(NOT WITH_BENCHMARK)
        return()
    endif()

    cmake_parse_arguments(ARG "" "" "SOURCES;LIBRARIES" ${ARGN})

    add_executable(${target} ${ARG_SOURCES})
    target_compile_features(${target} PRIVATE cxx_std_23)
    target_link_libraries(${target} PRIVATE ${ARG_LIBRARIES} benchmark::benchmark)
    project_apply_warnings(${target})
endfunction()
