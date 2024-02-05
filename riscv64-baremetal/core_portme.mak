# Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Original Author: Shay Gal-on

#File: core_portme.mak

# Flag: ARCH
#   RISC-V ISA specification string
ARCH ?= rv64imafdc
# Flag: ABI
#   RISC-V ABI
ABI ?= lp64d
ARCHFLAGS = -march=$(ARCH) -mabi=$(ABI)
# Flag: DEBUG
#   Enable debugging output
DEBUG ?=
# Flag: TICKS_PER_SEC
#   Hard-coded clock frequency of the tested CPU. Set to a reasonably low value
#   when running in a RTL simulation.
TICKS_PER_SEC ?=
# Flag: RISCVTOOLS
#	Use this flag to point to your RISCV tools
RISCVTOOLS=$(RISCV)
# Flag: RISCVTYPE
#   Type of toolchain to use
RISCVTYPE=riscv64-unknown-elf
# Flag: OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o
# Flag: CC
#	Use this flag to define compiler to use
CC = $(RISCVTOOLS)/bin/$(RISCVTYPE)-gcc
# Flag: CFLAGS
#	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
#PORT_CFLAGS = -O2 -static -std=gnu99
PORT_CFLAGS = $(ARCHFLAGS) -O2 -mcmodel=medany -static -std=gnu99 -fno-common -fno-tree-loop-distribute-patterns -nostdlib -nostartfiles -fno-builtin -lm -lgcc -T $(PORT_DIR)/link.ld
ifneq ($(TICKS_PER_SEC),)
  PORT_CFLAGS += -DEE_TICKS_PER_SEC=$(TICKS_PER_SEC)
endif
ifneq ($(DEBUG),)
  PORT_CFLAGS += -DCORE_DEBUG=1
endif
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS) $(XLFLAGS) $(LFLAGS_END)"
CFLAGS = $(PORT_CFLAGS) -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"
#Flag: LFLAGS_END
#	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts).
#	Note: On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
LFLAGS_END +=
# Flag: PORT_SRCS
# Port specific source files can be added here
PORT_SRCS = $(PORT_DIR)/core_portme.c $(PORT_DIR)/syscalls.c $(PORT_DIR)/crt.S $(PORT_DIR)/ee_printf.c barebones/cvt.c
# Flag: LOAD
#	Define this flag if you need to load to a target, as in a cross compile environment.

# Flag: RUN
#	Define this flag if running does not consist of simple invocation of the binary.
#	In a cross compile environment, you need to define this.

# Instead of copying and manually modifying ee_printf.c file its done on the fly:
# - uart_send_char() is marked as weak. It's implemented in a different file
# - the #error directive is removed
# - ee_printf() buffer is increased to 1KB
$(PORT_DIR)/ee_printf.c: barebones/ee_printf.c
	@sed '/uart_send_char(char c)/s/^/__attribute__((weak)) /' $< >$@
	@sed -ie '/#error/d' $@
	@sed -i 's/char buf\[256\]/char buf\[1024\]/g' $@

#For flashing and using a tera term macro, you could use
#LOAD = flash ADDR
#RUN =  ttpmacro coremark.ttl

#For copying to target and executing via SSH connection, you could use
#LOAD = scp $(OUTFILE)  user@target:~
#RUN = ssh user@target -c

#For native compilation and execution
LOAD = echo Loading done
RUN = spike pk

OEXT = .o
EXE = .bare.riscv

# Flag: SEPARATE_COMPILE
# Define if you need to separate compilation from link stage.
# In this case, you also need to define below how to create an object file, and how to link.
ifdef SEPARATE_COMPILE

LD		= $(RISCVTOOLS)/bin/$(RISCVTYPE)-gcc
OBJOUT 	= -o
LFLAGS 	=
OFLAG 	= -o
COUT 	= -c
# Flag: PORT_OBJS
# Port specific object files can be added here
PORT_OBJS = $(PORT_DIR)/core_portme$(OEXT)
PORT_CLEAN = *$(OEXT)

$(OPATH)%$(OEXT) : %.c
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

endif

# Target: port_prebuild
# Generate any files that are needed before actual build starts.
# E.g. generate profile guidance files. Sample PGO generation for gcc enabled with PGO=1
#  - First, check if PGO was defined on the command line, if so, need to add -fprofile-use to compile line.
#  - Second, if PGO reference has not yet been generated, add a step to the prebuild that will build a profile-generate version and run it.
#  Note - Using REBUILD=1
#
# Use make PGO=1 to invoke this sample processing.

ifdef PGO
 ifeq (,$(findstring $(PGO),gen))
  PGO_STAGE=build_pgo_gcc
  CFLAGS+=-fprofile-use
 endif
 PORT_CLEAN+=*.gcda *.gcno gmon.out
endif

.PHONY: port_prebuild
port_prebuild: $(PGO_STAGE)

.PHONY: build_pgo_gcc
build_pgo_gcc:
	$(MAKE) PGO=gen XCFLAGS="$(XCFLAGS) -fprofile-generate -DTOTAL_DATA_SIZE=1200" ITERATIONS=10 gen_pgo_data REBUILD=1

# Target: port_postbuild
# Generate any files that are needed after actual build end.
# E.g. change format to srec, bin, zip in order to be able to load into flash
.PHONY: port_postbuild
port_postbuild:

# Target: port_postrun
# 	Do platform specific after run stuff.
#	E.g. reset the board, backup the logfiles etc.
.PHONY: port_postrun
port_postrun:

# Target: port_prerun
# 	Do platform specific after run stuff.
#	E.g. reset the board, backup the logfiles etc.
.PHONY: port_prerun
port_prerun:

# Target: port_postload
# 	Do platform specific after load stuff.
#	E.g. reset the reset power to the flash eraser
.PHONY: port_postload
port_postload:

# Target: port_preload
# 	Do platform specific before load stuff.
#	E.g. reset the reset power to the flash eraser
.PHONY: port_preload
port_preload:

# FLAG: OPATH
# Path to the output folder. Default - current folder.
OPATH = ./
MKDIR = mkdir -p

# FLAG: PERL
# Define perl executable to calculate the geomean if running separate.
PERL=/usr/bin/perl
