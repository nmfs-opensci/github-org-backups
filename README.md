# github-org-backups

This shows you how to create a VM and set-up automatic GitHub organization backups.

1. Create a VM (on say Azure)
2. You'll need to associate a disk with that. Pick a disk that is big enough for what you are backing up
3. Create a admin username for the VM. e.g. `github-backups`
4. SSH in. Azure has a tool to SSH in the browser.
5. If you are not in as `github-backups`, then switch users with `sudo su - github-backups`
6. Create the directory `githubBackups` with `mkdir githubBackups`
7. Edit the `nmfs-opensci-backup.sh` file by adding in your GitHub org name.
8. Create a organizational level token.
9. Create the file `nmfs-opensci-backup.sh` with say `nano nmfs-opensci-backup.sh` and paste in the contents of the `nmfs-opensci-backup.sh` file.
