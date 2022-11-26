#!/usr/bin/bash

if (($# != 2)); then 
    echo "Command should be: ./script2.sh <line_no> <pattern>"    
else 
    for file in *; do 
        if [ $file != script2.sh ] &&  tail -$1 $file | head -1 | grep $2; then 
            echo $file
            rm "$file"
        fi
    done
fi