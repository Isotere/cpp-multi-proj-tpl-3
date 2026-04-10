# Plan: Трансформация шаблона в cpp-roadmap-tpl

## Контекст
Проект создан из общего шаблона для C++ проектов. Цель — превратить его в **GitHub template
repository** специально для проектов roadmap (AI + C++ обучение), где основной фокус:
консольные приложения, линейная алгебра, ML-алгоритмы, тесты, бенчмарки.

При создании нового репозитория из шаблона пользователь запускает `./setup.sh MyProject`
и все плейсхолдеры заменяются на реальные значения.

---

## 0. GitHub Template: плейсхолдеры и setup-скрипт

GitHub **не поддерживает** нативную подстановку переменных при создании из шаблона.
Стандартный подход — **setup-скрипт** (`setup.sh`), который делает find-and-replace
плейсхолдеров и удаляет себя после выполнения.

### Плейсхолдеры

| Плейсхолдер | Где используется | Пример подстановки |
|---|---|---|
| `__PROJECT_NAME__` | `CMakeLists.txt` → `project(...)`, README заголовок, Makefile подсказки | `cpp_roadmap` |
| `__PROJECT_DESCRIPTION__` | README описание | `AI + C++ Learning Roadmap` |
| `__AUTHOR_NAME__` | README | `Vyacheslav Tilikov` |

### Файлы с плейсхолдерами

- `CMakeLists.txt` — `project(__PROJECT_NAME__ VERSION ...)`
- `README.md` — заголовок, описание, автор
- `Makefile` — подсказки в help/init (`make <target>`)
- `CMakeLists.txt` — комментарий `day1_raii` → убрать, не нужен

### Задачи

- [ ] **0.1** Заменить `project(project_name ...)` → `project(__PROJECT_NAME__ ...)`
- [ ] **0.2** Заменить `day1_raii` в комментариях CMake и подсказках Makefile на `my_app`
  (нейтральное имя-пример, TARGET по умолчанию остаётся `hello_world`)
- [ ] **0.3** Написать `setup.sh`:
  - Принимает имя проекта как аргумент: `./setup.sh MyProject`
  - `sed` замена `__PROJECT_NAME__` → переданное имя во всех файлах
  - `sed` замена `__PROJECT_DESCRIPTION__` → опциональный 2-й аргумент или пустая строка
  - `sed` замена `__AUTHOR_NAME__` → берёт из `git config user.name`
  - Удаляет сам себя (`rm setup.sh`)
  - Удаляет `PLAN.md` если есть
  - Делает `git add -A && git commit -m "Initialize project from template"`
- [ ] **0.4** Добавить инструкцию в README: после "Use this template" → запусти `./setup.sh`

---

## 1. Удалить SFML

- [ ] **1.1** Удалить `src/sfml_example/` целиком
- [ ] **1.2** Удалить из корневого `CMakeLists.txt` блок FetchContent для SFML
  (строки 98-108: `SFML_BUILD_EXAMPLES`, `FetchContent_Declare(SFML)`, `FetchContent_MakeAvailable`)
- [ ] **1.3** Удалить `build/` (содержит кэшированные зависимости SFML — ogg, vorbis и т.д.)

## 2. Убрать Boost Test, добавить Google Test

- [ ] **2.1** Удалить `set(BOOST_ROOT ...)` и `option(WITH_BOOST_TEST ...)` из корневого `CMakeLists.txt`
- [ ] **2.2** Удалить блок `if(WITH_BOOST_TEST) enable_testing() endif`
- [ ] **2.3** Добавить FetchContent для **GoogleTest** (v1.16.0)
- [ ] **2.4** Добавить `enable_testing()` безусловно
- [ ] **2.5** Переписать `src/hello_world/CMakeLists.txt` — тесты через GTest вместо Boost
- [ ] **2.6** Переписать `src/hello_world/tests/test_version.cpp` на GoogleTest

## 3. Добавить Google Benchmark

- [ ] **3.1** Добавить FetchContent для **Google Benchmark** (v1.9.1)
- [ ] **3.2** Добавить опцию `WITH_BENCHMARK` (ON по умолчанию)
- [ ] **3.3** Добавить пример бенчмарка в hello_world (опционально, как образец)

## 4. Скорректировать hello_world

- [ ] **4.1** Упростить `main.cpp` — убрать version(), сделать чистый "Hello, World!"
  как стартовую точку
- [ ] **4.2** Убрать `lib.cpp`, `lib.h`, `version.h.in` — лишняя сложность для стартового примера
- [ ] **4.3** Упростить `src/hello_world/CMakeLists.txt` — минимальный пример
  (add_executable + warnings + тест)
- [ ] **4.4** Переписать тест на GTest (простой smoke test)

## 5. Очистить корневой CMakeLists.txt

- [ ] **5.1** Использовать плейсхолдер `__PROJECT_NAME__` в `project()` (см. шаг 0)
- [ ] **5.2** Удалить CPack (DEB-пакеты не нужны для учебных проектов)
- [ ] **5.3** Оставить `include_directories(libs)` — папка `libs/` предназначена для общих
  библиотек между подпроектами (Mini-Matrix, CSVReader, Plotter и т.д.).
  Создать `libs/.gitkeep` чтобы папка попала в git.
- [ ] **5.4** Убрать `set(BUILD_TARGET ...)` и условную компиляцию одного таргета —
  упростить до единого `file(GLOB ...)` с автодобавлением всех подпроектов
  (BUILD_TARGET усложняет шаблон; в Makefile уже есть `--target` для cmake --build)
- [ ] **5.5** Убрать лишний комментарий "Остальное без изменений"

## 6. Обновить Makefile

- [ ] **6.1** Добавить таргет `test` — запуск ctest
- [ ] **6.2** Добавить таргет `bench` — запуск бенчмарков
- [ ] **6.3** Обновить `new` — генерировать также заготовку для теста (tests/test_main.cpp)
- [ ] **6.4** Обновить подсказки — убрать `day1_raii`, использовать `hello_world`
- [ ] **6.5** Убрать `WITH_BOOST_TEST` из переменных, если был

## 7. Обновить конфигурационные файлы

- [ ] **7.1** Обновить `.gitignore` — добавить `bin/`, `*.dSYM`, `.DS_Store`, `datasets/`
- [ ] **7.2** Обновить `README.md` — написать полноценный README с плейсхолдерами:

  **Структура README:**

  1. **Заголовок + описание**
     - `# __PROJECT_NAME__`
     - `__PROJECT_DESCRIPTION__`

  2. **Что предоставляет шаблон** (Features)
     - Мульти-проектная структура (src/<project>/CMakeLists.txt)
     - C++23, Clang, Ninja
     - Google Test + Google Benchmark из коробки
     - AddressSanitizer + UBSan по умолчанию в Debug
     - clang-format + clangd настроены
     - Makefile с удобными командами
     - Папка `libs/` для общих библиотек между проектами
     - Папка `datasets/` для данных, `scripts/` для вспомогательных скриптов
     - Автодобавление новых подпроектов (make new TARGET=name)

  3. **Требования** (Prerequisites)
     - cmake >= 4.0, ninja, llvm/clang (homebrew), gnuplot (опционально)
     - Команды установки для macOS

  4. **Первичная инициализация** (Getting Started)
     - Шаг 1: создать репо из шаблона (Use this template)
     - Шаг 2: `./setup.sh MyProjectName` (заменяет плейсхолдеры, удаляет себя)
     - Шаг 3: `make init` (генерирует CMake, compile_commands.json)
     - Шаг 4: `make build` или `make TARGET=hello_world`

  5. **Команды Makefile** (таблица)
     - `make init` — инициализация проекта
     - `make build` — сборка всех целей
     - `make <TARGET>` / `make TARGET=name` — сборка и запуск одной цели
     - `make new TARGET=name` — создать новый подпроект из шаблона
     - `make test` — запуск тестов (ctest)
     - `make bench` — запуск бенчмарков
     - `make clean` — полная очистка build/
     - `make clean-target` — очистка одной цели
     - `make rebuild` / `make rebuild-target` — clean + build
     - `make release TARGET=name` — сборка в Release без санитайзеров
     - `make leaks TARGET=name` — проверка утечек (macOS leaks)
     - `make setup` — проверка системных зависимостей

  6. **Структура проекта** (дерево)
     ```
     .
     ├── CMakeLists.txt          # корневой CMake
     ├── Makefile                # удобные команды
     ├── cmake/                  # cmake-модули (warnings и т.д.)
     ├── libs/                   # общие библиотеки
     ├── src/                    # подпроекты
     │   └── hello_world/       # пример
     │       ├── CMakeLists.txt
     │       ├── main.cpp
     │       └── tests/
     ├── datasets/               # датасеты
     ├── scripts/                # вспомогательные скрипты
     └── setup.sh               # инициализация (удаляется после запуска)
     ```

  7. **Как добавить новый подпроект**
     - `make new TARGET=my_app` → создаёт src/my_app/ с main.cpp, CMakeLists.txt, tests/
     - Автоматически подхватывается при следующей сборке

  8. **Конфигурация**
     - CMake-опции: ENABLE_ASAN, ENABLE_UBSAN, WITH_BENCHMARK
     - CMakePresets: mac-debug, mac-release, mac-asan
- [ ] **7.3** Обновить `CMakePresets.json` — добавить sanitizer-пресеты (asan+ubsan)

## 8. Добавить полезные для roadmap вещи

- [ ] **8.1** Создать `datasets/.gitkeep` — папка для датасетов (Iris, Boston Housing)
- [ ] **8.2** Создать `scripts/.gitkeep` — папка для Python sanity-check скриптов
- [ ] **8.3** Добавить шаблонный `.clang-tidy` с разумными defaults

## 9. Очистка

- [ ] **9.1** Удалить `build/` из рабочей директории (перегенерируется)
- [ ] **9.2** Удалить `bin/` если есть артефакты
- [ ] **9.3** Убедиться что `compile_commands.json` симлинк (не файл) в .gitignore

---

## Что НЕ делаем (осознанно)

- **Не добавляем CLI11** — это зависимость конкретного проекта (miniml), не шаблона
- **Не добавляем Eigen** — это Phase 2, подключится через FetchContent в конкретном проекте
- **Не меняем C++23** — оставляем, это правильный выбор для обучения
- **Не убираем sanitizers** — они критичны для обучения
- **Не убираем ProjectWarnings.cmake** — хорошие практики с первого дня
- **Не добавляем CI** — это задача конкретного проекта (неделя 10 плана)

---

## Порядок выполнения

1. Удаление (SFML, Boost, лишние файлы) — шаги 1, 2.1-2.2, 4.2, 5.2-5.5
2. Добавление зависимостей (GTest, GBench) — шаги 2.3-2.4, 3
3. Обновление hello_world — шаги 4.1, 4.3-4.4
4. Плейсхолдеры в CMake и README — шаги 0.1-0.2, 5.1
5. Обновление Makefile — шаг 6
6. Обновление конфигов и README — шаги 7, 8
7. Setup-скрипт — шаги 0.3-0.4
8. Финальная очистка и проверка сборки — шаг 9
