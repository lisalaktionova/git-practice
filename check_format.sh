#!/bin/bash

check_format() {
	local cur_line_number=0
	local prev_line=""

	while IFS= read line; do
		cur_line_number=$((cur_line_number + 1))
		if [[ $cur_line_number -eq 1 ]]; then
			if [[ ! "$line" =~ ^Name\ of\ book:\ .+ ]]; then
				echo "Error in line $cur_line_number: Expected format 'Name of book: (any name)'" >&2
				return 1
			fi	
		elif [[ $cur_line_number -eq 2 ]]; then
			if [[ ! -n "$line" ]]; then
				echo "Error in line $cur_line_number: Expected empty line'" >&2
				return 1
			fi
		fi

		prev_line="$line"
	done < "$file"

	return 0		
}

changed_txt_files=$(git diff --cached --name-only --diff-filter=ACMR | grep ".txt\$")

for file in $changed_txt_files; do
	check_format "$file"
done

if [[ $? -ne 0 ]]; then
  echo "Commit is broken: Errors found in format." >&2
	exit 1
fi
