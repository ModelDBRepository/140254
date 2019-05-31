#! /bin/sh

if [ $# -ne 1 ]; then
         echo "Usage: "$0" n [input]"
         echo "       n     - Number of nodes"
         exit -1
fi

echo Create/clean up directories ...
echo ===============================

make -f ./Makefile

echo ===============================
echo ... done. Start simulation ...
echo ===============================

pgenesis -altsimrc startup/.psimrc prun.g -nodes $1

echo ===============================
echo ... done.
