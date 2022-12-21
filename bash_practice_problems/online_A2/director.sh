#!/usr/bin/bash
for file in *
do  
    [[ -f "$file" ]] || continue
    [[ "$file" =~ .txt$ ]] || continue
    dir=$(tail -2 "$file" | head -1)
    [[ -d "$dir/" ]] || mkdir "$dir"
    mv -t "$dir/" "$file"
done