#!/bin/bash

# Check if any argument is passed. If yes then check if it is an integer
(($# > 2)) && { echo 'can not process more than two parameters' & exit 1; }
(($# >= 1)) && { [[ $1 =~ ^[0-9]+$ ]] || { echo "Argument 1 should be a positive integer" & exit 1; } }
(($# == 2)) && { (($2 >= 1 && $2 <= 9)) || { echo "Argument 2 should be an integer between 1 to 9" & exit 1; } }
[ -d Submissions/ ] || { echo "Submissions/ does not exist. Please copy the shell file into the directory that contains Submissions" & exit 1; }

maxMarks=${1:-100}
maxStudentId=${2:-5}
start=1805121
end=$((start + maxStudentId - 1))

tempOutput="tempOutput.txt"
acceptedOutput="AcceptedOutput.txt"
output="output.csv"

touch $tempOutput
echo "student_id,score" > $output

for ((i="$start"; i<="$end"; i++)); do
    # if the submission does not contain a file named <student_id.sh>
    # then s/he should obtain 0
    script="Submissions/$i/$i.sh"
    # if the submission is not as described, give 0 and continue
    [ -f "$script" ] || { echo "$i,0" >> $output & continue; }
    obtainedMarks=$maxMarks

    # Grant execution permission if not exists
    [ -x "$script" ] || chmod a+x "$script"

    # Initial marking
    ./"$script" > $tempOutput
    numberOfLeftAngles=$(diff --ignore-all-space $acceptedOutput $tempOutput | grep -o '^<' | grep -c .)
    numberOfRightAngles=$(diff --ignore-all-space $acceptedOutput $tempOutput | grep -o '^>' | grep -c .)
    obtainedMarks=$((obtainedMarks-(numberOfLeftAngles+numberOfRightAngles)*5))
    # obtained marks can't be negative before copy checker
    ((obtainedMarks < 0)) && obtainedMarks=0
    
    # Copycheker
    for ((j="$start"; j<="$end"; j++)); do
        # Ignore if both files are the same
        ((i == j)) && continue
        otherScript="Submissions/$j/$j.sh"

        if diff "$script" "$otherScript" &>/dev/null; then
            obtainedMarks=$((-obtainedMarks))
            continue
        fi
    done
    # output
    echo "$i,$obtainedMarks" >> $output
done

rm $tempOutput