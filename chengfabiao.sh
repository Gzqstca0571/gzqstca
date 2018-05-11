#!/bin/bash
for x in `seq 9`
do
for y in `seq $x`
do
echo -n "$x*$y=$[x*y]	"
done
echo
done
