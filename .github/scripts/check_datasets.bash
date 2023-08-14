#!/bin/bash

error_found=0
dataset_dir=classification

# loop over all files in the directory
for file in $(dataset_dir)/*; do
    # check if file has .csv extension
    if [[ $file == *.csv ]]; then
        echo "Processing $file"

        # check for missing values
        if ! awk -F, '{for(i=1; i<=NF; i++) if($i ~ /^ *$/) exit 1}' "$file"; then
            echo "Error: $file contains missing values"
            error_found=1
        fi

        # get the number of fields (columns) in the file
        num_fields=$(awk -F, 'NR==1{print NF}' "$file")

        # check if each row has the same number of fields
        if ! awk -F, -v num_fields="$num_fields" '{if(NF != num_fields) exit 1}' "$file"; then
            echo "Error: All rows in $file do not have the same number of fields"
            error_found=1
        fi

        # check if the last field of each row is an integer (class)
        if ! awk -F, -v num_fields="$num_fields" '{if($num_fields !~ /^\s*[0-9]+\s*$/) exit 1}' "$file"; then
            echo "Error: Last field of each row in $file is not an integer (class)"
            error_found=1
        fi

        # check if there's more than one class
        num_classes=$(awk -F, -v num_fields="$num_fields" '{print $num_fields}' "$file" | sort -u | wc -l)
        if ((num_classes <= 1)); then
            echo "Error: $file does not contain more than one class"
            error_found=1
        fi

        # check if all other fields are numeric (integer or floating point)
        if ! awk -F, -v num_fields="$num_fields" '{for(i=1; i<=num_fields; i++) if($i !~ /^\s*-?(([0-9]+)|([0-9]*\.[0-9]+))(e-?[0-9]+)?\s*$/) exit 1}' "$file"; then
            echo "Error: Not all fields in $file are numeric"
            error_found=1
        fi

        # check for duplicate rows
        # Could create a separate branch which separates datasets with duplicate rows? What's the point of duplicate rows
        # Or indicate that the datasets might contain duplicate rows or not equal amount of classes (so they learn to address this issue themselves because it happens with real datasets)
        # if ! awk -F, '!seen[$0]++' "$file" | diff "$file" - > /dev/null ; then
        #     echo "Error: $file contains duplicate rows"
        #     error_found=1
        # fi
    else
        echo "Error: $file is not a CSV file"
        error_found=1
    fi
done

# if an error was found, exit with a non-zero exit code
if ((error_found == 1)); then
    echo "Checks failed"
    exit 1
fi
echo "Checks passed"

