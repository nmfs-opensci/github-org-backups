#!/bin/bash
# to run this script, 
# use the command: `bash backup.sh` at the terminal

#
# SYSTEM VARIABLES
#
# The name of your github organization
ORG_NAME="nmfs-opensci"

# A personal access token for your GH org
# that has the `read:user` and `read:org` scopes
ACCESS_TOKEN="ghp_caYDXXXXXX"

# The API version to use
API_VERSION="2022-11-28"

# The base URL
BASE_URL="https://api.github.com/orgs"

# Get the current date in the format MMDDYY
TODAY=$(date +%Y%m%d)

LOG="githubBackup/githubBackupLog.log"


#
# FUNCTIONS
#
# Function to backup a repository
