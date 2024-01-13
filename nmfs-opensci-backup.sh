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
ACCESS_TOKEN="ghp_caYDjvlYgXXXXXXXXXXXXXXXX"

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
backup_repo() {
  echo $(date) ": Starting backup" >> $LOG
  repo_names=$1
  curl -s -X POST \
       -H "Authorization: Bearer $ACCESS_TOKEN" \
       -H "Accept: application/vnd.github+json" \
       -H "X-GitHub-Api-Version: $API_VERSION" \
       -d '{"repositories":['$repo_names'],"lock_repositories":true}' \
       $BASE_URL/$ORG_NAME/migrations
}
# switch to true when deployed, false when testing


#Function to check on status of migration
check_on_status() {
  echo $(date) ": Starting check_on_status" >> $LOG
  mig_id=$1
  while true; do
    response=$(curl -s -H "Accept: application/vnd.github+json" \
                    -H "Authorization: Bearer $ACCESS_TOKEN"\
                    -H "X-GitHub-Api-Version: $API_VERSION" \
                    $BASE_URL/$ORG_NAME/migrations/$mig_id)

    # Check if the request was successful (HTTP status code 200)
    if [ "$?" -eq 0 ]; then
      # Parse the status of the migration from the response
      status=$(echo $response | jq -r '.state')
      echo $(date) ": The migration status ($mig_id) is: $status" >> $LOG
    else
      echo $(date) ": Failed to retrieve migration status ($mig_id)" >> $LOG
    fi

    # Check if all migrations have finished
    if [ $status == "exported" ]; then
      echo $(date) ": The migration is ready to be downloaded" >> $LOG
      break
    fi
    if [ $status == "failed" ]; then
      echo $(date) ": The migration has failed" >> $LOG
      break
    fi

    sleep 60
  done
}



# Function to download the backup of a repository
download_backup() {
  backup_id=$1
  echo $(date) ": Downloading backup: " $backup_id >> $LOG
  curl -s \
       -H "Authorization: Bearer $ACCESS_TOKEN" \
       -H "Accept: application/vnd.github+json" \
       -H "X-GitHub-Api-Version: $API_VERSION" \
       -L -o "$BACKUP_FOLDER/$ORG_NAME.tar.gz" \
       $BASE_URL/$ORG_NAME/migrations/$backup_id/archive
}


# Function to unlock a repository
unlock_repo() {
  backup_id=$1
  echo $(date) ": Unlocking repos in backup: " $backup_id >> $LOG
  unlock_repos=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
                      -H "Accept: application/vnd.github+json" \
                      -H "X-GitHub-Api-Version: $API_VERSION" \
                      $BASE_URL/$ORG_NAME/migrations/$backup_id/repositories | jq -r '.[].name')
   LOOP=1
   for unlock_repo in $unlock_repos; do
     echo $(date) ": Unlocking repo number " $LOOP ": "  $unlock_repo >> $LOG
     curl -s -X DELETE \
          -H "Authorization: Bearer $ACCESS_TOKEN" \
          -H "Accept: application/vnd.github+json" \
          -H "X-GitHub-Api-Version: $API_VERSION" \
          $BASE_URL/$ORG_NAME/migrations/$backup_id/repos/$unlock_repo/lock

    LOOP=$((LOOP + 1))
  done
}


# Function to delete an archive stored on github
delete_archive() {
  delete_id=$1
  echo $(date) ": Deleting archive: " $delete_id >> $LOG
  curl -s -X DELETE \
       -H "Authorization: Bearer $ACCESS_TOKEN" \
       -H "Accept: application/vnd.github+json" \
       -H "X-GitHub-Api-Version: $API_VERSION" \
       $BASE_URL/$ORG_NAME/migrations/$delete_id/archive
}



#
# MAIN CODE
#
# Create a folder with the current date
BACKUP_FOLDER="githubBackup/$TODAY"
mkdir -p $BACKUP_FOLDER

# Get a list of all repositories in the organization
PAGE_NUM=1
allRepos=""
while true; do
  repo_list=$(curl -s \
                   -H "Authorization: Bearer $ACCESS_TOKEN" \
                   -H "Accept: application/vnd.github+json" \
                   -H "X-GitHub-Api-Version: $API_VERSION" \
                   "$BASE_URL/$ORG_NAME/repos?per_page=100&page=$PAGE_NUM" \
                   | jq -r '.[].full_name')

  # Check if there are any more repos
  if [ -z "$repo_list" ]; then
    break
  fi

  for repo in $repo_list; do
    allRepos="$allRepos\"$repo\","
  done

  PAGE_NUM=$((PAGE_NUM + 1))
done

# remove last comma
allRepos=${allRepos%?}

echo $(date) ": Backing up repos: " $allRepos >> $LOG

backup_repo $allRepos

BACKUP_IDS=$(curl -i \
                  -H "Authorization: Bearer $ACCESS_TOKEN" \
                  -H "Accept: application/vnd.github+json" \
                  -H "X-GitHub-Api-Version: $API_VERSION" \
                  "$BASE_URL/$ORG_NAME/migrations?exclude=repositories" \
                  | grep '"id":')

echo $(date) ": All migration ids: " $BACKUP_IDS >> $LOG

first_id=$(echo $BACKUP_IDS | grep -o '"id": [0-9]*' | head -n1)
echo $(date) ": First ID: " $first_id >> $LOG
bk_id=$(echo $first_id | grep -o '[0-9]' | tr -d '\n')
echo $(date) ": Using ID#: " $bk_id >> $LOG

check_on_status $bk_id
download_backup $bk_id
unlock_repo $bk_id
delete_archive $bk_id
echo $(date) ": Backup complete" >> $LOG

