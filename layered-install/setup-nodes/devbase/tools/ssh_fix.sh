#!/bin/bash

user_folder=$USER
source_file_path="/mnt/c/Users/$user_folder/.ssh/id_rsa"
target_path="/home/$USER/.ssh"
overwrite_target="true"
fix_permissions="true"
run_default="true"
verbose="false"

echo_help(){
    echo "This script is used to setup your ssh profile inside wsl2.
By default, it will copy your id_rsa file from your {source_file_path} to the {targetpath}, and fix the permissions of the resulting file, allowing you to use SSH inside this WSL environment just as if you were using SSH outside in your Windows environment"
    usage
    echo "Details:
    Parameters:
        user_folder: the /user/ folder in windows you are looking for. Helpful if you want to use the default source_file_path parameter, but the user folder is called something different than the local WSL \$USER. Don't include the brackets / or \\
        source_file_path: the /path/to/file you want to copy
        target_path: the /path/to/target/folder you want to copy to
        overwrite_target: as required, mkdir and/or overwite file if it exists
        fix_permissions: chmod 700 the file after copying
        verbose: run verbosely
    Defaults:
        user_folder=$user_folder
        source_file_path=$source_file_path
        target_path=$target_path
        overwrite_target=$overwrite_target
        fix_permissions=$fix_permissions
        verbose=$verbose
    "
    exit 1
}

check_file(){
    # check if this string argument is an exising file
    local file_dir=$1
    if [ -f $file_dir ] && [ ! -z "$file_dir" ]
    then
        echo true
    else
        echo false
    fi
}

check_path(){
    # check if this string argument is a real directory
    local source_dir=$1
    if [ -d $source_dir ] && [ ! -z "$source_dir" ]
    then
        echo true
    else
        echo false
    fi
}

check_bool_arg(){
    # check if this string argument has a bool value of true
    local arg_string=$1
    if [ ! -z "$arg_string" ] 
    then
        if [ $arg_string = "true" ] || [ $arg_string = "True" ]
        then
            echo true
        else
            echo false
        fi
    else
        echo false
    fi
}

echo_params(){
    # echo out our expected variable values
    echo "source_file_path = $source_file_path"
    echo "target_path = $target_path"
    echo "overwrite_target = $overwrite_target"
    echo "fix_permissions = $fix_permissions"
    echo "verbose = $verbose"
}

check_args(){
    # check if our arguments are suitable to operate on
    if  ! [ $user_folder = $USER ]
    then
        source_file_path="/mnt/c/Users/$user_folder/.ssh/id_rsa"
    fi

    local source_file_path_check=$(check_file $source_file_path)
    local source_file=$(basename $source_file_path suffix)
    local target_source_file_path="$target_path/$source_file"
    local target_path_check=$(check_path $target_path)
    local target_file_check=$(check_path $target_source_file_path)
    local overwrite_check=$(check_bool_arg $overwrite_target)
    local fix_permissions_check=$(check_bool_arg $fix_permissions)

    if [ $verbose = "true" ] || [ $verbose = "True" ]
    then
        echo_params
        echo "source_file_path_check = $source_file_path_check"
        echo "source_file = $source_file"
        echo "target_path_check = $target_path_check"
        echo "target_file_check = $target_file_check"
        echo "overwrite_check = $overwrite_check"
        echo "fix_permissions_check = $fix_permissions_check"
    fi

    check_and_copy_file(){
        if ! [ $target_file_check ]
        then
            echo "Copying $source_file_path, to $target_source_file_path"
            cp $source_file_path $target_source_file_path
        elif [ $overwrite_check ]
        then
            if ! [ -d $target_path ]
            then
                echo "Making directory $target_path"
                mkdir -p $target_path
            fi
            echo "Copying $source_file_path, overwriting $target_source_file_path"
            yes | cp -rf $source_file_path $target_source_file_path
        else
            echo "$target_path is not a recognized folder, please enter a proper path to file"
            exit 1
        fi
    }

    if [ $source_file_path_check ]
    then

        if [ $target_path_check ] || [ $overwrite_check ]
        then
            check_and_copy_file
        else 
            echo "$target_path is not a recognized folder, please enter a proper path to file"
            exit 1
        fi
    else
        echo "$source_file_path is not a recognized file, please enter a proper path to file"
        exit 1
    fi

    if [ $fix_permissions_check ]
    then
        echo "Changing permissions for $target_source_file_path"
        sudo chmod 600 $target_source_file_path
    fi
    echo "Done setting up $source_file in WSL2 instance $HOSTNAME for user $USER "
}

usage() { 
    # print out the one-line usage tip
    exit=$1
    echo "Usage: $0 [-p run PARM1=VALUE1 PARM2=VALUE2 ... ] [-h]" 
    # if [[ -z "$exit" ]]; then exit=false else exit=check_bool_arg $exit fi 
    # if [$exit] then  1>&2; exit 1; 
    # main
}

main(){
    # collect the parameters and assign them to variables
    keys=()
    for ARGUMENT in "$@"
    do
        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        
        KEY_LENGTH=${#KEY}
        VALUE="${ARGUMENT:$KEY_LENGTH+1}"
        keys+=($KEY)
        export "$KEY"="$VALUE"
    done

    # check our arguments
    check_args
}

while getopts ":p:h" o; do
    case "${o}" in
        p)
            p=${OPTARG}
            ;;
        h)
            echo_help
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${p}" ] ; then
    usage;
    1>&2; exit 1; 
fi

main $p "$@"