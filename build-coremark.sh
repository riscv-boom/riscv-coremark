#!/bin/bash

set -e

BASEDIR=$PWD
CM_FOLDER=coremark

cd $BASEDIR/$CM_FOLDER

# run the compile
echo "Start compilation"
make PORT_DIR=../riscv64 compile
mv coremark.riscv ../

make PORT_DIR=../riscv64-baremetal ITERATIONS=1 compile
mv coremark.bare.riscv ../

cd $BASEDIR
riscv64-unknown-elf-objdump -D coremark.riscv > coremark.riscv.dump
riscv64-unknown-elf-objdump -D coremark.bare.riscv > coremark.bare.riscv.dump
