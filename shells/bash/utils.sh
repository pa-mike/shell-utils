#!/bin/bash


# Set ANSI Escape Codes for Text Coloring

green='\033[0;32m'
light_green='\033[1;32m'
blue='\033[0;34m'
light_cyan='\033[1;36m'
red='\033[1;31m'
no_color='\033[0m'
grey_color='\033[1;30m'
variable_color="${light_cyan}"
script_path_color="${blue}"
date_color="${green}"
error_color="${red}"
pass_color="${light_green}"
skipping_color="${grey_color}"
action_color="${green}"
line_trim_length=30
#Function to timestamp our readouts
timestamp_echo() {
    script_location="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    echo -e "${date_color}$(date) - ${script_path_color}$script_location -${no_color} $1"
}
test_pass_echo() {
    timestamp_echo "${pass_color}Pass:${no_color} $1"
}
test_fail_echo() {
    timestamp_echo "${error_color}Error:${no_color} $1"
}
skipping_echo() {
    timestamp_echo "${skipping_color}Skipping:${no_color} $1"
}
action_echo() {
    timestamp_echo "${action_color}Starting:${no_color} $1"
}
test_fail_summary(){
    test_fail_echo "Pre-run tests Failed, please see log above for details"
}

truncate_string(){
    echo $(echo "$1" | tr -d '\n' | sed "s/\(.\{$line_trim_length\}\).*/\1.../")
}

add_unique_line_to_file(){

    if [ "$3" == "force" ]; then
        action_echo "Adding line ${variable_color}'$(truncate_string "$1")'${no_color} to ${variable_color}'$(truncate_string $2)'${no_color}"
        echo "
$1" >> $2
    elif grep -zoq -F "\b$1\b" "$2"; then
        skipping_echo "Found existing line ${variable_color}'$(truncate_string "$1")'${no_color} in ${variable_color}'$(truncate_string $2)'${no_color}"
    else
        action_echo "Adding line ${variable_color}'$(truncate_string "$1")'${no_color} to ${variable_color}'$(truncate_string $2)'${no_color}"
        echo "
$1" >> $2
    fi
}