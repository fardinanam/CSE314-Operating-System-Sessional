#!/usr/bin/bash

changeExt() {
    parentDir="${1:-.}/"
    ext="${2:-cpp}"
    cExt="${3:-c}"
    # Iterate through cpp files and change the extensions
    for file in "$parentDir"*".$ext"  
    do
        [[ "$file" == "$parentDir*.$ext" ]] && break
        mv -v "$file" "${file%."$ext"}.$cExt"
    done
    # iterate through sub directories recursively
    for folder in "$parentDir"*/
    do  
        [[ "$folder" == "$parentDir*/" ]] && break
        changeExt "$folder" "$2" "$3"
    done
}

changeExt a cpp c