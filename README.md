# coremarkpro-util-make-riscv

This repository provides the utility files to port CoreMark-Pro to RISC-V.

**Purpose**

 Port RISC-V (RV64G) to CoreMark-Pro.
 
**Requirements**

  - You must have your own copy of EEMBC's [CoreMark-Pro](http://www.eembc.org/coremark/faq.php?b=pro).
  - You must have installed the RISC-V tools (preferably, the Linux-ELF/glibc toolchain).

**Setup**

  - Download and unpack CoreMark-Pro from [EEMBC's website](http://www.eembc.org/coremark/download.php?b=pro)
  - Copy `riscv64.mak` and `riscv-gcc64.mak` files into the `coremarkpro_1.1.2743/util/make` directory.

**Building Binaries**

    make TARGET=riscv64

**Running Binaries**

    make TARGET=riscv64 certify-all
