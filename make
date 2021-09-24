#!/usr/bin/bash
MAKEFILE_DIR=directory_of_central_makefile
cp $MAKEFILE_DIR/Makefile .
make $1 $2 SRCSDIR=srcs HDRSDIR=hdrs EXTRA_LFLAGS="" SELF="$MAKEFILE_DIR/Makefile"
rm -f Makefile
