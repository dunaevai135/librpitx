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

all: testrpitx 

CFLAGS	= -Wall -g -O3 -Wno-unused-variable
# Добавляем путь к заголовочным файлам userland, если они доступны
ifneq ($(wildcard $(BCM_HOST_INCLUDE_DIR)),)
  CFLAGS += -I$(BCM_HOST_INCLUDE_DIR)
endif
# Также проверяем системный путь для обратной совместимости
ifneq ($(wildcard /opt/vc/include),)
  CFLAGS += -I/opt/vc/include
endif
LDFLAGS	= -lm -lrt -lpthread $(BCM_HOST_LDFLAGS)
CCP = g++ 
CC = gcc 


testrpitx: testrpitx.cpp ../src/librpitx.h ../src/librpitx.a
	
	$(CCP) $(CFLAGS) -o testrpitx testrpitx.cpp ../src/librpitx.a $(LDFLAGS) 

clean:
	
	rm -f  testrpitx
