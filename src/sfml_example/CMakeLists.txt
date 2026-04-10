add_executable(sfml_example main.cpp)
target_compile_features(sfml_example PRIVATE cxx_std_23)
target_link_libraries(sfml_example PRIVATE SFML::Graphics)
project_apply_warnings(sfml_example)
