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


if [[ $(grep 'Ubuntu' /etc/os-release) =~ "Ubuntu" ]]
then
    wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh -O /tmp/Anaconda3-2021.11-Linux-x86_64.sh
    sudo bash /tmp/Anaconda3-2021.11-Linux-x86_64.sh -b -p $PREFIX
elif [[ $(grep 'darwin' /etc/os-release) =~ "darwin" ]]
then
    wget https://repo.anaconda.com/archive/Anaconda3-2021.11-MacOSX-x86_64.sh -O /tmp/Anaconda3-2021.11-MacOSX-x86_64.sh
    sudo bash /tmp/Anaconda3-2021.11-MacOSX-x86_64.sh -b -p $PREFIX
else
    printf "This script is unable to figure out if this is running on mac or linux, aboring..."
    exit 2
fi

printf "Initializing Conda for this target user's shell
"

sudo groupadd condaUsers
sudo chgrp -R condaUsers $PREFIX
# find $PREFIX -type d -exec chmod 755 {} \;
# find $PREFIX -type f -exec chmod 644 {} \;
sudo chmod 770 -R $PREFIX
sudo adduser $TARGETUSER condaUsers
sudo chown -R $TARGETUSER:$TARGETUSER $PREFIX

# Initialize conda
printf "Initializing Conda for this target user's shell
"
if [[ $SHELL = *zsh ]]
then
    sudo -H -u $TARGETUSER bash -c "$PREFIX/bin/conda init zsh"
else
    sudo -H -u $TARGETUSER bash -c "$PREFIX/bin/conda init"
fi


