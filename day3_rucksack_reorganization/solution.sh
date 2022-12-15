#!/bin/bash

# Retrieve characters which are duplicate in two lines
# $1 ... first string
# $2 ... second string
# $3 ... length of first string
# $4 ... length of second string
# echo: array of duplicate characters
find_duplicates () {
  first_comp="$1"
  second_comp="$2"
  length1="$3"
  length2="$4"
  
  comp_dups=()

  for (( i=0; i<length1; i++ )); do
      first_char="${first_comp:$i:1}"
      #echo "First Char is: $first_char"
      for (( j=0; j<length2; j++ )); do
        second_char="${second_comp:$j:1}"
        #echo "Second Char is: $second_char"
        if [ "$first_char"  ==  "$second_char" ];
        then
          comp_dups+=( $first_char )
        fi
      done
  done

      echo "${comp_dups[*]}"
}

# Remove duplicates from a given array
# $1 array with duplicates
# echo: list without duplicates
remove_duplicates() {
  input=("$@")
  result=( `for k in ${input[@]}; do echo $k; done | sort -u` )
  result=$input
  echo "${result[*]}"
}

# Given an array of characters, calculates the priorities
# As defined by the challenge
# $1: List of characters
# Echo: Sum of priorities
calculate_priority () {
 sum=0
 input=("$@")
 for element in ${input[@]}; 
  do
    value=$(printf "%d\n" "'$element")
    if [ $value -gt 97 ]; then
      let "sum += value - 96"
    else
      let "sum += value - 38"
    fi
  done

  echo $sum
}
 
echo "[Challenge Part 1 Start]"
echo "[Challenge Part 2 Start]"

total_priority=0 # Sums up the sum of priorities along compartments
total_priority_badges=0 # Sums up the badges of groups
badge_group=()

# Open the file for reading
while IFS= read -r line
do
  # Store items stored in both comps
  comp_duplicates=()

  length=${#line} # Get string length
  
  # Get Compartments
  first_comp=${line:0:length/2} 
  second_comp=${line:length/2:length/2}

  # echo "$first_comp -- $second_comp" 
  
  # Find duplicates between departments
  comp_duplicates=$(find_duplicates $first_comp $second_comp $((length/2)) $((length/2)))

  # Remove duplicate entries in the list
  comp_duplicates=$(remove_duplicates ${comp_duplicates[@]})

  # Calculate the priority of all items shared betwen compartments
  priority=$(calculate_priority ${comp_duplicates[@]})

  # Add elf to badge group
  badge_group+=($line)

  # Determine badge every three entries
  if [ ${#badge_group[@]} -eq 3 ]; then

    # Get shared entries between first two elves
    first_and_second=$(find_duplicates ${badge_group[0]} ${badge_group[1]} ${#badge_group[0]} ${#badge_group[1]})

    # Remove spaces
    first_and_second=$(echo "${first_and_second[*]}" | sed 's/ //g')

    # Find residue item with third elf
    badge=$(find_duplicates ${first_and_second[*]} ${badge_group[2]} ${#first_and_second} ${#badge_group[2]})

    # Calculate priority of item
    badge_priority=$(calculate_priority ${badge:0:1})

    # Add to total badges
    let "total_priority_badges += badge_priority"
    badge_group=()
  fi

  let "total_priority += priority"
done < "input.txt"

echo "[Challenge Part 1] Total Priority: ${total_priority}"
echo "[Challenge Part 2] Total Badge Priority: ${total_priority_badges}"


