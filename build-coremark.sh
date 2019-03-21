#!/bin/bash

set -e

BASEDIR=$PWD
CM_FOLDER=coremark

# if not existing checkout the repository
if [ ! -d "$BASEDIR/$CM_FOLDER" ]; then
    echo "Cloning the CoreMark repository"
    git clone https://github.com/eembc/coremark $BASEDIR/$CM_FOLDER
fi

# checkout the proper commit
cd $BASEDIR/$CM_FOLDER
echo "Checking out commit hash $(cat $BASEDIR/COREMARK_HASH)"
git fetch
git checkout $(cat $BASEDIR/COREMARK_HASH)

# copy over the files if they are not already present
if [ ! -d "riscv64" ]; then
    echo "Copying defaults over"
    cp -R $BASEDIR/riscv64 $BASEDIR/$CM_FOLDER
fi

# run the compile
echo "Start compilation"
make PORT_DIR=riscv64 compile
