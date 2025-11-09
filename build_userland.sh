#!/bin/bash
# Скрипт для скачивания и сборки libbcm_host из архивного репозитория userland

# Не прерываем выполнение при ошибках в проверках и поиске файлов
set -o pipefail

USERLAND_DIR="userland"
USERLAND_URL="https://github.com/raspberrypi/userland.git"
INSTALL_DIR="$(pwd)/userland_install"

echo "=== Сборка libbcm_host из архивного репозитория userland ==="

# Проверка наличия необходимых инструментов
if ! command -v cmake &> /dev/null; then
    echo "Ошибка: cmake не установлен. Установите его: sudo apt install cmake"
    exit 1
fi

if ! command -v gcc &> /dev/null; then
    echo "Ошибка: gcc не установлен. Установите его: sudo apt install gcc"
    exit 1
fi

# Клонирование репозитория, если его еще нет
if [ ! -d "$USERLAND_DIR" ]; then
    echo "Клонирование репозитория userland..."
    git clone "$USERLAND_URL" "$USERLAND_DIR"
else
    echo "Реопозиторий userland уже существует, обновляем..."
    cd "$USERLAND_DIR"
    git pull || true
    cd ..
fi

# Переход в директорию userland
cd "$USERLAND_DIR"

# Использование buildme для сборки
echo "Сборка libbcm_host..."

# Проверяем наличие скрипта buildme
if [ ! -f "./buildme" ]; then
    echo "Ошибка: скрипт buildme не найден в репозитории userland"
    exit 1
fi

# Делаем buildme исполняемым
chmod +x ./buildme

# Используем CMake напрямую для более точного контроля
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Конфигурация CMake
echo "Конфигурация CMake..."
if ! cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    -DBUILD_SHARED_LIBS=ON 2>&1 | tee cmake_config.log; then
    echo "Ошибка при конфигурации CMake"
    exit 1
fi

# Пытаемся собрать только bcm_host, если такая цель существует
echo "Попытка собрать libbcm_host..."
LIB_BUILT=0

# Пробуем разные варианты целей
for target in "bcm_host" "libbcm_host" "host_applications/libs/bcm_host"; do
    if cmake --build . --target "$target" 2>/dev/null; then
        echo "✓ Успешно собрана цель: $target"
        LIB_BUILT=1
        break
    fi
done

# Если не удалось собрать отдельную цель, собираем все host_applications
if [ $LIB_BUILT -eq 0 ]; then
    echo "Отдельная цель не найдена, собираем host_applications..."
    if ! cmake --build . --target host_applications 2>&1 | tail -20; then
        echo "Предупреждение: сборка host_applications завершилась с ошибками"
        echo "Попробуем найти уже собранные библиотеки..."
    fi
fi

# Установка в локальную директорию
echo "Поиск и копирование библиотеки в $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR/lib" "$INSTALL_DIR/include"

# Поиск собранной библиотеки в различных возможных местах
LIB_FOUND=0
SEARCH_PATHS=(
    "host_applications/libs/bcm_host"
    "libs/bcm_host"
    "interface/vmcs_host/linux"
    "build/interface/vmcs_host/linux"
)

for search_path in "${SEARCH_PATHS[@]}"; do
    if [ -f "$search_path/libbcm_host.so" ]; then
        echo "Найдена библиотека: $search_path/libbcm_host.so"
        cp "$search_path/libbcm_host.so"* "$INSTALL_DIR/lib/" 2>/dev/null || true
        LIB_FOUND=1
    fi
    if [ -f "$search_path/libbcm_host.a" ]; then
        echo "Найдена статическая библиотека: $search_path/libbcm_host.a"
        cp "$search_path/libbcm_host.a" "$INSTALL_DIR/lib/" 2>/dev/null || true
        LIB_FOUND=1
    fi
done

# Также ищем в корне build директории
find . -name "libbcm_host.so*" -type f -exec cp {} "$INSTALL_DIR/lib/" \; 2>/dev/null && LIB_FOUND=1 || true
find . -name "libbcm_host.a" -type f -exec cp {} "$INSTALL_DIR/lib/" \; 2>/dev/null && LIB_FOUND=1 || true

# Копирование заголовочных файлов
echo "Копирование заголовочных файлов..."
HEADER_PATHS=(
    "../interface/vmcs_host/linux"
    "../host_support/include"
    "interface/vmcs_host/linux"
    "host_support/include"
)

for header_path in "${HEADER_PATHS[@]}"; do
    if [ -d "$header_path" ]; then
        echo "Копирование из: $header_path"
        cp -r "$header_path"/* "$INSTALL_DIR/include/" 2>/dev/null || true
    fi
done

cd ../..

# Проверка результата
if [ $LIB_FOUND -eq 1 ]; then
    echo "✓ libbcm_host успешно собрана!"
    echo "Библиотека находится в: $INSTALL_DIR/lib"
    ls -lh "$INSTALL_DIR/lib/"*bcm_host* 2>/dev/null || true
    if [ -d "$INSTALL_DIR/include" ]; then
        echo "Заголовочные файлы находятся в: $INSTALL_DIR/include"
    fi
else
    echo "Предупреждение: библиотека не найдена в ожидаемом месте"
    echo "Попытка найти библиотеку..."
    find "$USERLAND_DIR" -name "*bcm_host*" -type f 2>/dev/null | head -5 || echo "Библиотека не найдена"
    echo ""
    echo "Попробуйте собрать вручную:"
    echo "  cd $USERLAND_DIR"
    echo "  ./buildme"
fi

