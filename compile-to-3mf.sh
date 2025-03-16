#!/bin/bash

for m in {1..15}
do
    file="multiplication/$(printf '%02dx.scad' ${m})"
    cp spinner-multiplication.scad $file
    #awk -v a="m=${m};" 'NR==3 { sub(".*insert-m-here", a) }' $file
    sed -E -i "3s/.*/m=${m};/" $file
    colorscad.sh -i "$file" -o "${file%.scad}.3mf" -f
done


for m in {1..15}
do
    file="addition(printf '%02dx.scad' ${m})"
    cp spinner-addition.scad $file
    #awk -v a="m=${m};" 'NR==3 { sub(".*insert-m-here", a) }' $file
    sed -E -i "3s/.*/m=${m};/" $file
    colorscad.sh -i "$file" -o "${file%.scad}.3mf" -f
done
