Coremark EEMBC Wrapper
======================

This repository provides the utility files to port [CoreMark EEMBC](https://www.eembc.org/coremark/) to RISC-V.

### Requirements

  - You must have installed the RISC-V tools

### Setup

  - `git submodule update --init`
  - Run the `./build-coremark.sh` script that does the following
    - Clones the [CoreMark repository](https://github.com/eembc/coremark) and checks out the hash found in `COREMARK_HASH`
    - Copies the `riscv64` repository to the `coremark` repo
    - Compiles the binary (location is `coremark/coremark.riscv`)

### Default Files

The default files target **RV64GC** and use minimal amount of compilation flags. Additionally, the `*.mak` file in the `riscv64`
folder setups `spike pk` as the default `run` rule.

Feel free to change these to suit your needs.
