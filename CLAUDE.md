# CLAUDE.md — __PROJECT_NAME__

## Проект

__PROJECT_DESCRIPTION__

## Сборка

```bash
make init          # первичная инициализация (CMake + Ninja + compile_commands)
make build         # сборка всех целей
make run TARGET=x  # сборка и запуск одной цели
make test          # ctest
make bench         # Google Benchmark
make new TARGET=x  # создать новый подпроект из шаблона
```

Компилятор: Homebrew LLVM (`/opt/homebrew/opt/llvm/bin/clang++`).
Генератор: Ninja. Стандарт: C++23.

## Структура

```
src/<target>/           — подпроекты (каждый со своим CMakeLists.txt)
src/<target>/tests/     — тесты (GTest)
src/<target>/bench/     — бенчмарки (Google Benchmark)
libs/                   — header-only библиотеки (доступны через include_directories)
datasets/               — данные, если нужны
cmake/                  — CMake-модули (ProjectWarnings.cmake, ProjectTargets.cmake)
bin/                    — собранные бинарники (gitignored)
build/                  — build directory (gitignored)
scripts/                — вспомогательные скрипты
```

Новый подпроект: `make new TARGET=my_app` создаёт `src/my_app/` с `main.cpp`,
`tmp.cpp` (общая lib), `CMakeLists.txt`, тестами и бенчем. Подпроект автоматически
подхватывается рутовым CMakeLists через `file(GLOB)` по `src/*/CMakeLists.txt`.

## CMake helpers (cmake/ProjectTargets.cmake)

Подпроекты используют декларативные функции вместо boilerplate:

```cmake
project_add_library(my_lib SOURCES a.cpp b.cpp INCLUDE_CURRENT_DIR)
project_add_executable(my_app SOURCES main.cpp LIBRARIES my_lib)
project_add_gtest(test_my_app SOURCES tests/test_main.cpp LIBRARIES my_lib)
project_add_benchmark(bench_my_app SOURCES bench/bench_my_app.cpp LIBRARIES my_lib)
```

Все функции автоматически применяют warnings (`project_apply_warnings`) и
`cxx_std_23`. `project_add_gtest` сам делает `gtest_discover_tests`.
`project_add_benchmark` — no-op если `WITH_BENCHMARK=OFF`.

## Стиль кода

- Clang-format: LLVM style (`.clang-format` в корне)
- Clang-tidy: настроен (`.clang-tidy` в корне), `HeaderFilterRegex: 'src/.*|libs/.*'`
- Warnings: `-Wall -Wextra -Wpedantic -Werror` + дополнительные (см. `cmake/ProjectWarnings.cmake`)
- Sanitizers: ASan и UBSan включены по умолчанию в Debug (`make build`).
  Отключить: `make build ASAN=OFF UBSAN=OFF`. Release всегда без санитайзеров.

## Зависимости (FetchContent)

- Google Test v1.17.0
- Google Benchmark v1.9.5 (выключается через `-DWITH_BENCHMARK=OFF`)

## CMake опции

| Опция | По умолчанию | Описание |
|---|---|---|
| `ENABLE_ASAN` | `OFF` | AddressSanitizer (Makefile включает в Debug) |
| `ENABLE_UBSAN` | `OFF` | UBSan (Makefile включает в Debug) |
| `ENABLE_NATIVE_ARCH` | `ON` | `-march=armv8.4-a+...` для Apple Silicon |
| `WITH_BENCHMARK` | `ON` | Подключить Google Benchmark |

## Полезное

- `compile_commands.json` симлинкуется в корень при `make init`/`make build` для clangd/IDE.
- На macOS Debug + sanitizers требуют `-O1` (выставляется автоматически).
- Утечки на macOS: `make leaks TARGET=x ASAN=OFF UBSAN=OFF` (через системный `leaks`).
