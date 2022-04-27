# This is a special script which intermixes both powershell and shell script. 


#!/bin/bash

function DoBashThings {
    wget http://www.example.org/my.script -O my.script
    # set a couple of environment variables
    export script_source=http://www.example.org
    export some_value=floob
    # now execute the downloaded script
    bash ./my.script
}

"DoBashThings"  # This runs the bash script, in PS it's just a string
"exit"          # This quits the bash version, in PS it's just a string


# PowerShell code here
# --------------------
Invoke-WebRequest "http://www.example.org/my.script.ps1" -OutFile my.script.ps1
$env:script_source="http://www.example.org"
$env:some_value="floob"
PowerShell -File ./my.script.ps1