#!/bin/sh
nasm -felf64 tuning_trouble.asm && ld tuning_trouble.o -o tuning_trouble
./tuning_trouble
