#!/usr/bin/bash
MAKEFILE_DIR=directory_of_central_makefile

cp $MAKEFILE_DIR/Makefile .
make $1 $2 SRCSDIR=srcs HDRSDIR=hdrs EXTRA_LFLAGS="" CENTRAL_MAKEFILE_DIR="$MAKEFILE_DIR"
rm -f Makefile
