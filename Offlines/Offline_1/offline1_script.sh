#!/bin/bash

# Check if any argument is passed. If yes then check if it is an integer
(($# >= 1)) && { [[ $1 =~ ^[0-9]+$ ]] || { echo "Argument should be an integer" && exit 1; } }
cd Submissions/ || { echo "\'Submissions/\' does not exist" && exit 1; }

maxMarks=100
if (($# != 0)); then
    maxMarks=$1
fi
studentIds=($(ls))
obtainedMarks=()
tempOutput="tempOutput.txt"
acceptedOutput="../AcceptedOutput.txt"
output="../output.csv"

touch ../$tempOutput
echo "student_id,score" > $output

for i in "${!studentIds[@]}"; do
    # if the submission does not contain a file named <student_id.sh>
    # then s/he should obtain 0
    script="${studentIds[$i]}"
    script="$script/$script.sh"
    [ -f "$script" ] || { obtainedMarks[$i]=0 && continue; }
    obtainedMarks[$i]=$maxMarks

    # Grant execution permission if not exists
    [ -x "$script" ] || chmod a-x "$script"

    # Initial marking
    ./"$script" > ../$tempOutput
    numberOfLeftAngles=$(diff --ignore-all-space $acceptedOutput ../$tempOutput | grep -o '<' | grep -c .)
    numberOfRightAngles=$(diff --ignore-all-space $acceptedOutput ../$tempOutput | grep -o '>' | grep -c .)
    obtainedMarks[$i]=$((obtainedMarks[i]-(numberOfLeftAngles+numberOfRightAngles)*5))
    # obtained marks can't be negative before copy checker
    ((obtainedMarks[i] < 0)) && obtainedMarks[$i]=0
    
    # Copycheker
    for othersFolder in "${studentIds[@]}"; do
        # Ignore if both files are the same
        [ "$othersFolder" == "${studentIds[$i]}" ] && continue

        if diff "$script" "$othersFolder/$othersFolder.sh" &>/dev/null; then
            obtainedMarks[$i]=-"${obtainedMarks[$i]}"
            continue
        fi
    done
    # output
    echo "${studentIds[$i]},${obtainedMarks[$i]}" >> $output
done

cd .. && rm $tempOutput