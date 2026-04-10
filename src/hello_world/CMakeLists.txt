add_executable(hello_world main.cpp)
target_compile_features(hello_world PRIVATE cxx_std_23)
project_apply_warnings(hello_world)

# --- Tests ---
add_executable(test_hello_world tests/test_main.cpp)
target_link_libraries(test_hello_world PRIVATE GTest::gtest_main)
project_apply_warnings(test_hello_world)

include(GoogleTest)
gtest_discover_tests(test_hello_world)
