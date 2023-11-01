#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

if [ "$#" -ge 2 ]; then
    echo "Usage: $0 [-r] [-a] <file1> <file2>"
    exit 1
fi

reverse_sort=false
alphabetical_sort=false

while getopts "ra" opt; do
    case "$opt" in
        r)
            reverse_sort=true
            ;;
        a)
            alphabetical_sort=true
            ;;
        \?)
            echo "Usage: $0 [-r] [-a] <file1> <file2>"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

declare -A data1
declare -A data2

while read -r size path; do
    data1["$path"]=$size
done < "$1"

while read -r size path; do
    data2["$path"]=$size
done < "$2"

show_difference() {
    local path=$1
    local size1=${data1[$path]}
    local size2=${data2[$path]}

    if [ -z "$size1" ] && [ -z "$size2" ]; then
        echo "0 $path"  
    elif [ -z "$size1" ]; then
        echo "$size2 $path NEW"  # Directory/file added
    elif [ -z "$size2" ]; then
        echo "$size1 $path REMOVED"  # Directory/file removed
    else
        local diff=$((size2 - size1))
        echo "$diff $path"
    fi
}

# Display the differences and handle sorting options
if [ "$reverse_sort" = true ] && [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -r -k2
elif [ "$reverse_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -r -k1
elif [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -k2
else
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -k1
fi
