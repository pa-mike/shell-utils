#! /bin/bash

PREFIX=$HOME/anaconda3
TARGETUSER=$USER

if which getopt > /dev/null 2>&1; then
    OPTS=$(getopt bfhp:sut "$*" 2>/dev/null)
    if [ ! $? ]; then
        printf "%s\\n" "$USAGE"
        exit 2
    fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -p)
                PREFIX="$2"
                shift
                shift
                ;;
            -u)
                TARGETUSER="$2"
                shift
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$1"
                exit 1
                ;;
        esac
    done
else
    while getopts "bfhp:sut" x; do
        case "$x" in
            p)
                PREFIX="$OPTARG"
                ;;
            ?)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$x"
                exit 1
                ;;
        esac
    done
fi

sudo apt-get update
sudo apt-get install curl -y

echo "Installing Anaconda3"
sudo bash ../setup-nodes/devbase/tools/install-conda.sh -p $PREFIX -u $TARGETUSER

echo "Done Data Setup Script"