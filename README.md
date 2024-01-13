# github-org-backups

This shows you how to create a VM and set-up automatic GitHub organization backups.

## On GitHub

1. Create personal access token at https://github.com/settings/tokens. Give it read:user and read:org scopes. It doesn't need more than that. You will need a reminder to renew it when it expires.
2. Save the personal access token (PAT) for the next step.
3. The PAT allows you to download more files from the GitHub API

## On your computer

1. Edit the `nmfs-opensci-backup.sh` file by adding in your GitHub org name and the personal access token where called for in the script. Don't push to GitHub if you are storing it there because the access token given read access to private repos in the org.

## On some machine. Let's say a VM.

1. Create a VM (on say Azure)
2. You'll need to associate a disk with that. Pick a disk that is big enough for what you are backing up
3. Create a admin username for the VM. e.g. `github-backups`
4. SSH in. Azure has a tool to SSH in the browser.
5. If you are not in as `github-backups`, then switch users with `sudo su - github-backups`
6. Create the directory `githubBackup` with `mkdir githubBackup`
9. Create the file `nmfs-opensci-backup.sh` with say `nano nmfs-opensci-backup.sh` and paste in the contents of the `nmfs-opensci-backup.sh` file.
10. Create a cron job with `crontab -e` and paste in the info in the `crontab` file

Done.

## Changing the script to take org name as a parameter

* Change this line in the script `ORG_NAME="nmfs-opensci"` to `ORG_NAME="$1"`
* Change this line in the crontab file from `` to ``
