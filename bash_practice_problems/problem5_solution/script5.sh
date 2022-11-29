#!/usr/bin/bash

count=0

#  clear the output files
>out.txt
>err.txt

# Iterate until error occurs
while ( ./test.sh >> out.txt 2>> err.txt ); do
    ((count++))
done

echo "Failed after $count runs"