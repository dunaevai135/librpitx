# Главный Makefile для проекта librpitx
# Автоматически собирает userland библиотеку при необходимости

.PHONY: all clean install userland clean-userland

USERLAND_INSTALL_DIR = $(shell pwd)/userland_install
USERLAND_LIB_DIR = $(USERLAND_INSTALL_DIR)/lib

# Проверка наличия локальной библиотеки userland
USERLAND_EXISTS = $(or $(wildcard $(USERLAND_LIB_DIR)/libbcm_host.so),$(wildcard $(USERLAND_LIB_DIR)/libbcm_host.a))

all: userland
	@echo "Сборка librpitx..."
	$(MAKE) -C src all

install: all
	$(MAKE) -C src install

# Сборка userland библиотеки, если она еще не собрана
userland:
	@if [ ! -f "$(USERLAND_LIB_DIR)/libbcm_host.so" ] && [ ! -f "$(USERLAND_LIB_DIR)/libbcm_host.a" ]; then \
		if [ ! -f "/opt/vc/lib/libbcm_host.so" ] && [ ! -f "/opt/vc/lib/libbcm_host.a" ]; then \
			echo "libbcm_host не найдена, запускаем сборку из архивного репозитория..."; \
			./build_userland.sh; \
		else \
			echo "Используется системная libbcm_host из /opt/vc/lib"; \
		fi \
	else \
		echo "Локальная libbcm_host уже собрана"; \
	fi

clean:
	$(MAKE) -C src clean
	$(MAKE) -C app clean

clean-userland:
	rm -rf userland userland_build userland_install

clean-all: clean clean-userland

