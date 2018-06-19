#!/bin/sh
ARCHIVE=archive/test1.arch
BODY_BEGINNING=$(head -n1 $ARCHIVE | sed 's/[0-9]*:\([0-9]*\)/\1/g')
