# Project warning flags and helper.

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(PROJECT_WARNING_FLAGS
            -Wall -Wextra -Wpedantic -Werror
            -Wshadow -Wnon-virtual-dtor -Wold-style-cast
            -Wcast-align -Wunused -Woverloaded-virtual
            -Wnull-dereference -Wdouble-promotion -Wformat=2
    )
endif()

function(project_apply_warnings target)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options(${target} PRIVATE ${PROJECT_WARNING_FLAGS})
    endif()
endfunction()
