#!/bin/bash

# loop over all files in the directory
for file in *; do
    # check if file has .csv extension
    if [[ $file == *.csv ]]; then
        echo "Processing $file"

        # check if data is comma-separated and doesn't contain spaces
        if ! awk -F, '{for(i=1; i<=NF; i++) if($i ~ / /) exit 1}' "$file"; then
            echo "Error: $file contains spaces or is not comma-separated"
            continue
        fi

        # get the number of fields (columns) in the file
        num_fields=$(awk -F, 'NR==1{print NF}' "$file")

        # check if the last field of each row is an integer (class)
        if ! awk -F, -v num_fields="$num_fields" '{if($num_fields !~ /^[0-9]+$/) exit 1}' "$file"; then
            echo "Error: Last field of each row in $file is not an integer (class)"
            continue
        fi

        # check if classes start from 0 and increment by 1
        if ! awk -F, -v num_fields="$num_fields" 'BEGIN{prev=-1} {if($num_fields != prev + 1) exit 1; else prev++}' "$file"; then
            echo "Error: Classes in $file do not start from 0 and increment by 1"
            continue
        fi

        # check if there's more than one class
        num_classes=$(awk -F, -v num_fields="$num_fields" '{print $num_fields}' "$file" | sort -u | wc -l)
        if ((num_classes <= 1)); then
            echo "Error: $file does not contain more than one class"
            continue
        fi

        # check if all rows have the same number of fields
        if ! awk -F, -v num_fields="$num_fields" '{if(NF != num_fields) exit 1}' "$file"; then
            echo "Error: All rows in $file do not have the same number of fields"
            continue
        fi

        # check if all fields are numeric (integer or floating point)
        if ! awk -F, '{for(i=1; i<=NF; i++) if($i !~ /^[0-9]+(\.[0-9]+)?$/) exit 1}' "$file"; then
            echo "Error: All fields in $file are not numeric"
            continue
        fi

        echo "$file passed all checks"
    else
        echo "Error: $file is not a CSV file"
        error_found=1
    fi
done

# if an error was found, exit with a non-zero exit code
if ((error_found == 1)); then
    exit 1
fi
