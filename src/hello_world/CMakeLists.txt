project_add_library(hello_world_lib
    SOURCES
        tmp.cpp
    INCLUDE_CURRENT_DIR
)

project_add_executable(hello_world
    SOURCES
        main.cpp
    LIBRARIES
        hello_world_lib
)

project_add_gtest(test_hello_world
    SOURCES
        tests/test_main.cpp
    LIBRARIES
        hello_world_lib
)

project_add_benchmark(bench_hello_world
    SOURCES
        bench/bench_hello_world.cpp
    LIBRARIES
        hello_world_lib
)
