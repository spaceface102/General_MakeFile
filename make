#!/usr/bin/bash
MAKEFILE_DIR=~/Documents/General_MakeFile
cp $MAKEFILE_DIR/Makefile .
make $1 $2 SRCSDIR=srcs HDRSDIR=hdrs EXTRA_LFLAGS=""
rm -f Makefile
