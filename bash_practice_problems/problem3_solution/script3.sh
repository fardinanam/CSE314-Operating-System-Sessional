#!/usr/bin/bash

# for file in *; do    
#     if [ -f "$file" ]; then 
#         if [[ "$file" =~ [0-9]+ ]]; then
#            rm -i "$file"
#         fi
#     fi
# done

if [[ 1 =~ ^[0-9]+$ ]]; then
 echo okay
fi