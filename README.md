**librpitx** Radio frequency transmitter library for Raspberry Pi (B, B+, PI2, PI3 and PI zero)

It is now the base of *rpitx* project, separate from application

_Copyright (c) Evariste Courjaud F5OEO. Code is GPL_V3

# Installation

## Для Raspberry Pi OS Bookworm и выше

Начиная с RPiOS Bookworm, библиотека `libbcm_host` больше не доступна в системных пакетах (пакет `libraspberrypi0` устарел). Проект автоматически собирает необходимую библиотеку из архивного репозитория [raspberrypi/userland](https://github.com/raspberrypi/userland).

### Автоматическая сборка (рекомендуется)

```sh
git clone https://github.com/F5OEO/librpitx
cd librpitx
make
```

Главный Makefile автоматически:
1. Проверит наличие `libbcm_host` в системе или локально
2. При необходимости запустит скрипт `build_userland.sh` для сборки библиотеки из архивного репозитория
3. Соберет `librpitx` с использованием локальной библиотеки

### Ручная сборка userland

Если нужно собрать библиотеку вручную:

```sh
./build_userland.sh
cd src
make
```

### Для старых версий RPiOS (Bullseye и ниже)

Если у вас установлен пакет `libraspberrypi0`, можно использовать системную библиотеку:

```sh
cd librpitx/src
make
```

## Очистка

Очистить собранные файлы:
```sh
make clean
```

Очистить также локально собранную библиотеку userland:
```sh
make clean-userland
```

Очистить всё:
```sh
make clean-all
```
