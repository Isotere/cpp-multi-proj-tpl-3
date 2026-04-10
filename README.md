# __PROJECT_NAME__

__PROJECT_DESCRIPTION__

## Что предоставляет этот шаблон

- **Мульти-проектная структура** — каждый подпроект в `src/<name>/` со своим `CMakeLists.txt`, автоматически подхватывается при сборке
- **C++23** + Clang (Homebrew LLVM) + Ninja
- **Google Test** — подключён через FetchContent, готов к использованию в каждом подпроекте
- **Google Benchmark** — подключён через FetchContent для микробенчмарков
- **AddressSanitizer + UBSan** — включены по умолчанию в Debug-сборке
- **clang-format + clangd + clang-tidy** — настроены, `compile_commands.json` генерируется автоматически
- **Makefile** — удобные команды для сборки, тестов, бенчмарков, создания новых подпроектов
- **Папка `libs/`** — для общих библиотек, используемых несколькими подпроектами
- **Папка `datasets/`** — для датасетов (CSV, текстовые файлы и т.д.)
- **Папка `scripts/`** — для вспомогательных скриптов (sanity checks, визуализация и т.д.)
## Требования

```bash
# macOS (Homebrew)
brew install cmake ninja llvm

# Опционально
brew install gnuplot            # визуализация из C++
pip3 install numpy scikit-learn # sanity checks для ML-проектов
```

| Зависимость | Минимальная версия | Назначение |
|---|---|---|
| CMake | 4.0 | Система сборки |
| Ninja | любая | Быстрый бэкенд для CMake |
| LLVM/Clang | 17+ | Компилятор (C++23, sanitizers) |
| gnuplot | любая | Визуализация (опционально) |

## Первичная инициализация

### 1. Создать репозиторий из шаблона

Нажми **"Use this template"** на GitHub, или:

```bash
git clone <url> my-project
cd my-project
```

### 2. Настроить имя проекта

```bash
./setup.sh MyProjectName "Описание проекта"
```

Скрипт заменит все плейсхолдеры (`__PROJECT_NAME__`, `__PROJECT_DESCRIPTION__`, `__AUTHOR_NAME__`) на реальные значения, сделает начальный коммит и удалит себя.

### 3. Инициализировать сборку

```bash
make setup  # проверить что все зависимости установлены
make init   # сгенерировать CMake + compile_commands.json
```

### 4. Собрать и запустить

```bash
make build              # собрать всё
make test               # запустить тесты
make run TARGET=hello_world # собрать и запустить одну цель
```

## Команды Makefile

| Команда | Описание |
|---|---|
| `make init` | Инициализация проекта (CMake + compile_commands) |
| `make build` | Сборка всех целей |
| `make run TARGET=<name>` | Сборка и запуск одной цели |
| `make new TARGET=<name>` | Создать новый подпроект из шаблона |
| `make test` | Запуск всех тестов (ctest) |
| `make bench` | Запуск бенчмарков |
| `make clean` | Полная очистка build/ |
| `make clean-target` | Очистка одной цели |
| `make rebuild` | clean + build |
| `make rebuild-target` | clean-target + build target |
| `make release TARGET=<name>` | Сборка в Release без санитайзеров |
| `make leaks TARGET=<name>` | Проверка утечек через macOS `leaks` |
| `make setup` | Проверка системных зависимостей |
| `make help` | Показать все доступные команды |

### Переменные

| Переменная | По умолчанию | Описание |
|---|---|---|
| `TARGET` | `hello_world` | Цель для сборки/запуска |
| `BUILD_TYPE` | `Debug` | `Debug` или `Release` |
| `ASAN` | `ON` | AddressSanitizer |
| `UBSAN` | `ON` | UndefinedBehaviorSanitizer |

## Структура проекта

```
.
├── CMakeLists.txt              # Корневой CMake (зависимости, настройки компиляции)
├── Makefile                     # Удобные команды
├── setup.sh                    # Инициализация из шаблона (удаляется после запуска)
├── cmake/
│   └── ProjectWarnings.cmake   # Флаги предупреждений
├── libs/                       # Общие библиотеки между подпроектами
├── src/                        # Подпроекты
│   └── hello_world/            # Пример подпроекта
│       ├── CMakeLists.txt
│       ├── main.cpp
│       └── tests/
│           └── test_main.cpp
├── datasets/                   # Датасеты (CSV, текстовые файлы)
├── scripts/                    # Вспомогательные скрипты
├── .clang-format               # Настройки форматирования
├── .clang-tidy                 # Настройки линтера
└── .clangd                     # Настройки LSP
```

## Как добавить новый подпроект

```bash
make new TARGET=my_app
```

Создаст:
- `src/my_app/main.cpp` — точка входа
- `src/my_app/CMakeLists.txt` — сборка + тесты (GTest)
- `src/my_app/tests/test_main.cpp` — заготовка теста

Подпроект автоматически подхватится при следующей сборке (`make build`).

## Как добавить общую библиотеку

Общие библиотеки, используемые несколькими подпроектами, размещаются в `libs/`.
Папка `libs/` уже добавлена в `include_directories`, поэтому заголовки доступны
из любого подпроекта через `#include "my_lib/my_lib.h"`.

## Конфигурация CMake

| Опция | По умолчанию | Описание |
|---|---|---|
| `ENABLE_ASAN` | `OFF` | AddressSanitizer (включается через Makefile) |
| `ENABLE_UBSAN` | `OFF` | UndefinedBehaviorSanitizer (включается через Makefile) |
| `ENABLE_NATIVE_ARCH` | `ON` | Оптимизация под Apple Silicon |
| `WITH_BENCHMARK` | `ON` | Подключить Google Benchmark |

