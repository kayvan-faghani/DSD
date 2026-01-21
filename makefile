NIOS2_SHELL := C:\intelFPGA_lite\23.1std\nios2eds\Nios II Command Shell.bat

BSP_DIR  := software/hello_world_bsp
SET_PATH := software/hello_world_bsp/settings.bsp
APP_DIR  := software/hello_world

.PHONY: all bsp hello_world download run

all: bsp hello_world download terminal

bsp:
	"$(NIOS2_SHELL)" nios2-bsp-generate-files.exe --bsp-dir "$(BSP_DIR)" --settings "$(SET_PATH)"
# 	"$(NIOS2_SHELL)" make -C "$(BSP_DIR)" all

hello_world:
	"$(NIOS2_SHELL)" make -C "$(APP_DIR)" all

download:
	-"$(NIOS2_SHELL)" make -C "$(APP_DIR)" download-elf DOWNLOAD="nios2-download --accept-bad-sysid"

terminal:
	"$(NIOS2_SHELL)" nios2-terminal.exe

elf_size:
	"$(NIOS2_SHELL)" nios2-elf-size.exe software/hello_world/hello_world.elf

run: download terminal
