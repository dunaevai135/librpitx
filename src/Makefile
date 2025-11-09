# Путь к локально собранной библиотеке userland
USERLAND_INSTALL_DIR ?= $(shell cd .. && pwd)/userland_install
USERLAND_LIB_DIR = $(USERLAND_INSTALL_DIR)/lib
USERLAND_INCLUDE_DIR = $(USERLAND_INSTALL_DIR)/include

# Проверка наличия локальной библиотеки, иначе используем системную
ifeq ($(wildcard $(USERLAND_LIB_DIR)/libbcm_host.so),)
  ifeq ($(wildcard $(USERLAND_LIB_DIR)/libbcm_host.a),)
    # Локальная библиотека не найдена, используем системную (если доступна)
    BCM_HOST_LIB_DIR = /opt/vc/lib
    BCM_HOST_INCLUDE_DIR = /opt/vc/include
    BCM_HOST_LDFLAGS = -L$(BCM_HOST_LIB_DIR) -lbcm_host
  else
    # Используем локальную статическую библиотеку
    BCM_HOST_LIB_DIR = $(USERLAND_LIB_DIR)
    BCM_HOST_INCLUDE_DIR = $(USERLAND_INCLUDE_DIR)
    BCM_HOST_LDFLAGS = -L$(BCM_HOST_LIB_DIR) -lbcm_host
  endif
else
  # Используем локальную динамическую библиотеку
  BCM_HOST_LIB_DIR = $(USERLAND_LIB_DIR)
  BCM_HOST_INCLUDE_DIR = $(USERLAND_INCLUDE_DIR)
  BCM_HOST_LDFLAGS = -L$(BCM_HOST_LIB_DIR) -lbcm_host -Wl,-rpath,$(BCM_HOST_LIB_DIR)
endif

CFLAGS ?= -Wall -O3 -Wno-unused-variable
CFLAGS += -std=c++11 -fPIC
CXXFLAGS ?= -std=c++11 -Wall -O3 -Wno-unused-variable
CXXFLAGS += -std=c++11 -Wall -O3 -Wno-unused-variable -fPIC
# Добавляем путь к заголовочным файлам userland, если они доступны
ifneq ($(wildcard $(BCM_HOST_INCLUDE_DIR)),)
  CXXFLAGS += -I$(BCM_HOST_INCLUDE_DIR)
endif
# Также проверяем системный путь для обратной совместимости
ifneq ($(wildcard /opt/vc/include),)
  CXXFLAGS += -I/opt/vc/include
endif
LDFLAGS ?= -lm -lrt -lpthread $(BCM_HOST_LDFLAGS)
LDFLAGS += -fPIC
CXX ?= c++
CC ?= cc
PREFIX ?= /usr/local/
SRCCC=$(wildcard *.c)
SRCXX=$(wildcard *.cpp)
OBJS=$(SRCCC:.c=.o)
OBJS+=$(SRCXX:.cpp=.o)

# Проверка наличия локальной библиотеки перед сборкой
check_userland:
	@if [ ! -f "$(USERLAND_LIB_DIR)/libbcm_host.so" ] && [ ! -f "$(USERLAND_LIB_DIR)/libbcm_host.a" ]; then \
		if [ ! -f "/opt/vc/lib/libbcm_host.so" ] && [ ! -f "/opt/vc/lib/libbcm_host.a" ]; then \
			echo "Предупреждение: libbcm_host не найдена. Запустите ./build_userland.sh для сборки локальной версии."; \
			echo "Продолжаем сборку без libbcm_host..."; \
		fi \
	fi

all: check_userland librpitx.a librpitx.so

%.o: %.c
	$(CXX) $(CFLAGS) -c $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $^

librpitx.a: $(OBJS)
	$(AR) rc $@ $^

librpitx.so: $(OBJS)
	$(CXX) -fPIC -shared -o $@ $^ $(LDFLAGS) 

install: librpitx.a
	mkdir -p $(PREFIX)/include/librpitx
	install *.h $(PREFIX)/include/librpitx
	mkdir -p $(PREFIX)/lib
	install librpitx.a $(PREFIX)/lib

clean:
	rm -f $(OBJS) *.a *.so

clean-userland:
	rm -rf ../userland ../userland_build ../userland_install
