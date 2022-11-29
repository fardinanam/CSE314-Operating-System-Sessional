#!/usr/bin/bash

changeExt() {
    parentDir="${1:-.}"
    # Iterate through cpp files and change the extensions
    for cppFile in "$parentDir"/*.cpp; do 
        [[ "$cppFile" == "$parentDir/*.cpp" ]] && break
        # echo $cppFile
        mv -v "$cppFile" "${cppFile%.cpp}.c"
    done
    # iterate through sub directories recursively
    for dir in "$parentDir/"*/; do
        # echo "$dir"
        [[ "$dir" == "$parentDir/*/" ]] && break
        changeExt "$dir"
    done
}

changeExt a/