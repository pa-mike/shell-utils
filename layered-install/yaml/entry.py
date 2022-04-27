
# Working on converting powershell scripts to py files to make them platform agnostic and flexible

import argparse
import os
import subprocess
import requests
import logging

def powershell(cmd, args = None):
    if args is None:
        args = ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", cmd]
    completed = subprocess.run(args, capture_output=True, check=True)
    logging.info(completed.stdout.decode('UTF-8'))
    logging.debug(completed)
    return completed

def bash(cmd):
    completed = subprocess.run(["bash", "-c", cmd], capture_output=True, check=True)
    logging.info(completed.stdout.decode('UTF-8'))
    logging.debug(completed)
    return completed

def setup_package_manager(source_os):
    if source_os == "Darwin" or source_os == "Ubuntu":
        bash("")

def winget_install(package_id, source = "winget"):
    completed = powershell(f'. .\\functions.ps1; winget_install "{package_id}" "{source}"')
    return completed

def brew_install(package_id):
    completed = bash(f'brew install {package_id}')
    return completed

def install_brew():
    return bash("$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")
    
