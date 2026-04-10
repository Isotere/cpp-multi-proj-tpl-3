SHELL := /bin/bash
BUILD_DIR := build
SRC_DIR := src
COMPILE_COMMANDS := compile_commands.json

# Настройки по умолчанию
TARGET ?= hello_world
BUILD_TYPE ?= Debug
ASAN ?= ON
UBSAN ?= ON
# По умолчанию используем clang++ из Homebrew LLVM.
# При желании можно переопределить: make build CXX=/usr/bin/clang++
CC  := /opt/homebrew/opt/llvm/bin/clang
CXX := /opt/homebrew/opt/llvm/bin/clang++

# Команда CMake для полной сборки (все цели)
CMAKE_ALL = \
	cmake -S . -B $(BUILD_DIR) \
		-G Ninja \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DCMAKE_C_COMPILER=$(CC) \
		-DCMAKE_CXX_COMPILER=$(CXX) \
		-DCMAKE_OBJC_COMPILER=$(CC) \
		-DCMAKE_OBJCXX_COMPILER=$(CXX) \
		-DENABLE_ASAN=$(ASAN) \
		-DENABLE_UBSAN=$(UBSAN)

# Проверка существования цели
TARGET_EXISTS = $(shell [ -d "$(SRC_DIR)/$(TARGET)" -a -f "$(SRC_DIR)/$(TARGET)/CMakeLists.txt" ] && echo 1 || echo 0)

.PHONY: init
# ------------------------------------------------------------------------
# Инициализация проекта: make init
# ------------------------------------------------------------------------
init:
	@echo "Инициализация проекта..."
	@mkdir -p $(BUILD_DIR)
	@echo "  -> Генерация CMake..."
	@$(CMAKE_ALL)
	@echo "  -> Сборка compile_commands.json..."
	@cmake --build $(BUILD_DIR) --target help
	@$(MAKE) link-cc
	@echo "Проект инициализирован. Готов к разработке."
	@echo "Совет: используй 'make build' или 'make run TARGET=my_app'"

# Симлинк compile_commands.json в корень (если ещё не создан)
.PHONY: link-cc
link-cc:
	@if [ ! -L $(COMPILE_COMMANDS) ] && [ -f $(BUILD_DIR)/$(COMPILE_COMMANDS) ]; then \
		ln -sf $(BUILD_DIR)/$(COMPILE_COMMANDS) ./ ; \
		echo "  -> Создан симлинк: $(COMPILE_COMMANDS) -> $(BUILD_DIR)/$(COMPILE_COMMANDS)"; \
	fi

# ------------------------------------------------------------------------
# Сборка ВСЕГО проекта
# ------------------------------------------------------------------------
.PHONY: build
build:
	@echo "Сборка ВСЕХ целей..."
	@$(CMAKE_ALL) >/dev/null
	@cmake --build $(BUILD_DIR) -- -j$(shell sysctl -n hw.logicalcpu 2>/dev/null || nproc)
	@$(MAKE) link-cc

.PHONY: rebuild
rebuild: clean build

# ------------------------------------------------------------------------
# Сборка ОДНОЙ цели
# ------------------------------------------------------------------------
.PHONY: run
run:
ifeq ($(TARGET_EXISTS),0)
	$(error Цель '$(TARGET)' не найдена. Проверь: $(SRC_DIR)/$(TARGET)/)
endif
	@echo "Собираю $(TARGET)..."
	@$(CMAKE_ALL) >/dev/null
	@cmake --build $(BUILD_DIR) --target $(TARGET) -- -j$(shell sysctl -n hw.logicalcpu 2>/dev/null || nproc)
	@$(MAKE) link-cc
	@echo "$(TARGET) собран. Запуск:"
	@./bin/$(TARGET)

.PHONY: rebuild-target
rebuild-target: clean-target run

# ------------------------------------------------------------------------
# Тесты
# ------------------------------------------------------------------------
.PHONY: test
test: build
	@echo "Запуск тестов..."
	@cd $(BUILD_DIR) && ctest --output-on-failure

# ------------------------------------------------------------------------
# Бенчмарки
# ------------------------------------------------------------------------
.PHONY: bench
bench: build
	@echo "Запуск бенчмарков..."
	@find $(BUILD_DIR) -name "bench_*" -type f -perm +111 -exec echo "-> {}" \; -exec {} \;

# ------------------------------------------------------------------------
# Очистка
# ------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "Полная очистка build/"
	@rm -rf $(BUILD_DIR)
	@rm -rf ./bin/*
	@rm -f $(COMPILE_COMMANDS)

.PHONY: clean-target
clean-target:
	@mkdir -p $(BUILD_DIR)
	@$(CMAKE_ALL) >/dev/null
	@cmake --build $(BUILD_DIR) -- -t clean $(TARGET) 2>/dev/null || true
	@rm -f ./bin/$(TARGET)

# ------------------------------------------------------------------------
# Анализ (macOS)
# ------------------------------------------------------------------------
.PHONY: leaks
leaks: run
ifeq ($(ASAN),ON)
	@echo "ASan включён -> leaks не работает."
	@echo "Собери без ASan:"
	@echo "   make TARGET=my_app ASAN=OFF UBSAN=OFF leaks"
else
	@echo "Проверка утечек через leaks (macOS)..."
	@leaks --atExit -- ./bin/$(TARGET) 2>/dev/null || true
endif

release: BUILD_TYPE := Release
release: ASAN := OFF
release: UBSAN := OFF
release: run
	@echo "Собрано в Release: ./bin/$(TARGET)"

# ------------------------------------------------------------------------
# Вспомогательные
# ------------------------------------------------------------------------
.PHONY: setup
setup:
	@echo "Проверка зависимостей..."
	@which cmake &>/dev/null || { echo "cmake не установлен. Выполни: brew install cmake"; exit 1; }
	@which ninja &>/dev/null || { echo "ninja не установлен. Выполни: brew install ninja"; exit 1; }
	@which $(CXX) &>/dev/null || { echo "clang++ не найден по $(CXX). Установи: brew install llvm"; exit 1; }
	@echo "Все зависимости на месте."

new:
ifeq ($(TARGET),)
	$(error Укажи TARGET=name)
endif
	@mkdir -p $(SRC_DIR)/$(TARGET)/tests
	@echo '#include <iostream>' > $(SRC_DIR)/$(TARGET)/main.cpp
	@echo ''  >> $(SRC_DIR)/$(TARGET)/main.cpp
	@echo 'int main() {' >> $(SRC_DIR)/$(TARGET)/main.cpp
	@echo '    std::cout << "Hello from $(TARGET)\n";' >> $(SRC_DIR)/$(TARGET)/main.cpp
	@echo '    return 0;' >> $(SRC_DIR)/$(TARGET)/main.cpp
	@echo '}' >> $(SRC_DIR)/$(TARGET)/main.cpp
	@echo 'add_executable($(TARGET) main.cpp)' > $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo 'target_compile_features($(TARGET) PRIVATE cxx_std_23)' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo 'project_apply_warnings($(TARGET))' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo '' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo '# --- Tests ---' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo 'add_executable(test_$(TARGET) tests/test_main.cpp)' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo 'target_link_libraries(test_$(TARGET) PRIVATE GTest::gtest_main)' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo 'project_apply_warnings(test_$(TARGET))' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo '' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo 'include(GoogleTest)' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo 'gtest_discover_tests(test_$(TARGET))' >> $(SRC_DIR)/$(TARGET)/CMakeLists.txt
	@echo '#include <gtest/gtest.h>' > $(SRC_DIR)/$(TARGET)/tests/test_main.cpp
	@echo '' >> $(SRC_DIR)/$(TARGET)/tests/test_main.cpp
	@echo 'TEST($(TARGET), SmokeTest) {' >> $(SRC_DIR)/$(TARGET)/tests/test_main.cpp
	@echo '    EXPECT_EQ(1 + 1, 2);' >> $(SRC_DIR)/$(TARGET)/tests/test_main.cpp
	@echo '}' >> $(SRC_DIR)/$(TARGET)/tests/test_main.cpp
	@echo "Шаблон создан: $(SRC_DIR)/$(TARGET)/"
	@echo "  -> $(SRC_DIR)/$(TARGET)/main.cpp"
	@echo "  -> $(SRC_DIR)/$(TARGET)/CMakeLists.txt"
	@echo "  -> $(SRC_DIR)/$(TARGET)/tests/test_main.cpp"

.PHONY: help
help:
	@echo "Доступные команды:"
	@echo "  make init                    - Инициализация проекта (CMake + compile_commands)"
	@echo "  make build                   - Сборка всех целей"
	@echo "  make run TARGET=<name>       - Сборка и запуск одной цели"
	@echo "  make new TARGET=<name>       - Создать новый подпроект из шаблона"
	@echo "  make test                    - Запуск всех тестов (ctest)"
	@echo "  make bench                   - Запуск бенчмарков"
	@echo "  make clean                   - Полная очистка build/"
	@echo "  make clean-target            - Очистка одной цели"
	@echo "  make rebuild                 - clean + build"
	@echo "  make rebuild-target          - clean-target + build target"
	@echo "  make release TARGET=<name>   - Сборка в Release без санитайзеров"
	@echo "  make leaks TARGET=<name>     - Проверка утечек (macOS)"
	@echo "  make setup                   - Проверка системных зависимостей"
	@echo ""
	@echo "Переменные:"
	@echo "  TARGET=<name>   Цель для сборки (default: hello_world)"
	@echo "  BUILD_TYPE=<t>  Debug|Release (default: Debug)"
	@echo "  ASAN=ON|OFF     AddressSanitizer (default: ON)"
	@echo "  UBSAN=ON|OFF    UBSan (default: ON)"
