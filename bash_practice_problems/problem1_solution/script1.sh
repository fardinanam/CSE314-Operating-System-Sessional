#!/usr/bin/bash

if [[ $# -eq 0 ]]; then 
    echo No arguments passed
else 
    for file in "$@"; do 
        if ! test -e "$file"; then 
            echo "$file does not exist"
        elif ! test -f "$file"; then
           echo "$file is not a regular file"           
        elif test -x "$file"; then
            echo "$file is currently executable"
            ls -l "$file"
            echo "$file's permission is now changing"
            chmod a-x "$file"
            if test -x "$file"; then
                echo "Error changing execution permission of $file"
            else 
                ls -l "$file"
                echo "$file is not currently executable"
            fi
        else
            ls -l "$file" 
        fi
    done 
fi