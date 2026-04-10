file(GLOB_RECURSE HEADER_LIST CONFIGURE_DEPENDS "${PROJECT_SOURCE_DIR}/src/hello_world/*.h")
file(GLOB_RECURSE SOURCES_LIST CONFIGURE_DEPENDS "${PROJECT_SOURCE_DIR}/src/hello_world/*.cpp")

# Соберет .h файлик и положит его в директорию cmake
configure_file(version.h.in version.h)

add_executable(hello_world main.cpp)
add_library(hello_world_lib lib.cpp)

target_compile_features(hello_world PRIVATE cxx_std_23)
project_apply_warnings(hello_world)
project_apply_warnings(hello_world_lib)

# Говорим где искать собранный .h файл из .h.in файла
target_include_directories(hello_world_lib
        PRIVATE ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(hello_world PRIVATE hello_world_lib)

if (WITH_BOOST_TEST)
    find_package(Boost COMPONENTS unit_test_framework REQUIRED)

    add_executable(test_hello_world tests/test_version.cpp)

    set_target_properties(test_hello_world PROPERTIES
            COMPILE_DEFINITIONS BOOST_TEST_DYN_LINK
    )

    target_link_libraries(test_hello_world Boost::unit_test_framework hello_world_lib)
    project_apply_warnings(test_hello_world)

    add_test(test_hello_world test_hello_world)
endif ()
