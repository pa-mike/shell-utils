sudo apt update
sudo apt-get install python3 python3-pip python-as-python3 -y
sudo pip install --upgrade pip
/bin/python3 -m pip install -U pylint # Use /bin/python3 for global install, if a user has anaconda it will fail with regular pip
