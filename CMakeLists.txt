cmake_minimum_required(VERSION 4.0)

set(PATCH_VERSION "1" CACHE INTERNAL "Patch version")
set(PROJECT_VERSION 0.0.${PATCH_VERSION})

project(__PROJECT_NAME__ VERSION 0.0.${PATCH_VERSION})

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    # -g: symbols для профайлера
    # -O3: максимальная оптимизация
    # -DNDEBUG: отключает assert
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g -O3")
endif()

# === Определяем SDK ТОЛЬКО ПОСЛЕ project() и компилятора ===
if(APPLE)
    if(NOT CMAKE_OSX_SYSROOT)
        execute_process(
                COMMAND xcrun --show-sdk-path
                OUTPUT_VARIABLE SDK_PATH
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
        )
        if(NOT SDK_PATH)
            message(FATAL_ERROR "Не найден macOS SDK. Выполни: xcode-select --install")
        endif()
        set(CMAKE_OSX_SYSROOT "${SDK_PATH}" CACHE STRING "" FORCE)
        message(STATUS "Используется macOS SDK: ${SDK_PATH}")
    endif()

    if(NOT CMAKE_OSX_ARCHITECTURES)
        set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Build architectures")
    endif()
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Let's nicely support folders in IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# === Флаги компиляции ===
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    option(ENABLE_NATIVE_ARCH "Enable optimized arch flags for Apple Silicon" ON)
    if(ENABLE_NATIVE_ARCH AND (CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64"))
        add_compile_options(-march=armv8.4-a+fp16+simd+crc+crypto)
    endif()

    if(APPLE)
        # -stdlib=libc++ — ОБЯЗАТЕЛЬНО для Homebrew Clang!
        # Но только для C++/ObjC++, чтобы не ломать компиляцию C/ObjC.
        add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>)
        add_compile_options($<$<COMPILE_LANGUAGE:OBJCXX>:-stdlib=libc++>)
        add_link_options(-stdlib=libc++)

        # Если используем Homebrew LLVM, линковаться нужно с его libc++
        if(CMAKE_CXX_COMPILER MATCHES "/opt/homebrew/opt/llvm")
            add_link_options(-L/opt/homebrew/opt/llvm/lib/c++)
            add_link_options(-Wl,-rpath,/opt/homebrew/opt/llvm/lib/c++)
        endif()

        # Debug + sanitizers требуют -O1 на macOS
        add_compile_options($<$<CONFIG:Debug>:-O1>)
    endif()

    # Санитайзеры
    option(ENABLE_ASAN "Enable AddressSanitizer" OFF)
    option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" OFF)

    if(ENABLE_ASAN)
        add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
        add_link_options(-fsanitize=address)
    endif()
    if(ENABLE_UBSAN)
        add_compile_options(-fsanitize=undefined -fno-omit-frame-pointer)
        add_link_options(-fsanitize=undefined)
    endif()
endif()

include(cmake/ProjectWarnings.cmake)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin")

include_directories(libs)

# === Зависимости ===
include(FetchContent)

# Google Test
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.16.0
    GIT_SHALLOW ON
    EXCLUDE_FROM_ALL
    SYSTEM
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Google Benchmark
option(WITH_BENCHMARK "Whether to build Google Benchmark" ON)
if(WITH_BENCHMARK)
    set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_WERROR OFF CACHE BOOL "" FORCE)
    FetchContent_Declare(
        googlebenchmark
        GIT_REPOSITORY https://github.com/google/benchmark.git
        GIT_TAG v1.9.1
        GIT_SHALLOW ON
        EXCLUDE_FROM_ALL
        SYSTEM
    )
    FetchContent_MakeAvailable(googlebenchmark)
endif()

enable_testing()

# === Подпроекты ===
file(GLOB TARGET_DIRS RELATIVE ${CMAKE_SOURCE_DIR}/src ${CMAKE_SOURCE_DIR}/src/*)
foreach(dir ${TARGET_DIRS})
    if(IS_DIRECTORY "${CMAKE_SOURCE_DIR}/src/${dir}" AND EXISTS "${CMAKE_SOURCE_DIR}/src/${dir}/CMakeLists.txt")
        add_subdirectory("src/${dir}")
    endif()
endforeach()
