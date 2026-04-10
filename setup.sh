#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# setup.sh — инициализация проекта из шаблона
#
# Использование:
#   ./setup.sh <ProjectName> ["Project description"]
#
# Заменяет плейсхолдеры во всех файлах проекта и делает начальный коммит.
# После выполнения скрипт удаляет сам себя.
# ============================================================================

if [ $# -lt 1 ]; then
    echo "Использование: ./setup.sh <ProjectName> [\"Project description\"]"
    echo ""
    echo "Примеры:"
    echo "  ./setup.sh cpp_roadmap"
    echo "  ./setup.sh cpp_roadmap \"AI + C++ Learning Roadmap\""
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DESCRIPTION="${2:-}"
AUTHOR_NAME=$(git config user.name 2>/dev/null || echo "__AUTHOR_NAME__")

echo "Инициализация проекта..."
echo "  Имя:        $PROJECT_NAME"
echo "  Описание:   ${PROJECT_DESCRIPTION:-(не задано)}"
echo "  Автор:      $AUTHOR_NAME"
echo ""

# Список файлов для замены (исключаем бинарные, build, .git, сам скрипт обработаем отдельно)
FILES=$(find . \
    -not -path './.git/*' \
    -not -path './build/*' \
    -not -path './bin/*' \
    -not -path './setup.sh' \
    -type f \
    \( -name '*.txt' -o -name '*.cmake' -o -name '*.json' -o -name '*.md' \
       -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.in' \
       -o -name 'Makefile' -o -name '.clangd' -o -name '.clang-format' \
       -o -name '.clang-tidy' -o -name '.gitignore' \))

for file in $FILES; do
    if grep -q '__PROJECT_NAME__\|__PROJECT_DESCRIPTION__\|__AUTHOR_NAME__' "$file" 2>/dev/null; then
        sed -i '' \
            -e "s/__PROJECT_NAME__/${PROJECT_NAME}/g" \
            -e "s/__PROJECT_DESCRIPTION__/${PROJECT_DESCRIPTION}/g" \
            -e "s/__AUTHOR_NAME__/${AUTHOR_NAME}/g" \
            "$file"
        echo "  -> $file"
    fi
done

# Удаляем PLAN.md если есть (это план трансформации шаблона, не нужен в проекте)
if [ -f PLAN.md ]; then
    rm PLAN.md
    echo "  -> Удалён PLAN.md"
fi

# Начальный коммит
git add -A
git commit -m "Initialize project ${PROJECT_NAME} from template"

echo ""
echo "Готово! Проект '$PROJECT_NAME' инициализирован."
echo ""
echo "Следующие шаги:"
echo "  make setup   # проверить зависимости"
echo "  make init    # сгенерировать CMake"
echo "  make build   # собрать всё"
echo "  make test    # запустить тесты"

# Удаляем сам скрипт
rm -- "$0"
