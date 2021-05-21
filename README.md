# Polling / sync projects to your gitlab server 
This Gitlab CICD pipeline template for you to config which projects to be synced to your own gitlab server using CICD pipeline

# Prerequsite 
This project assumes you've been familiar with:
1. Setup gitlab CICD pipeline
2. Manage secrets in gitlab 
3. Basic git operations

# Sync projects

## Create a group in your gitlab service
1. Create a group to contain the exporter and the projects to sync
## Clone the projects to your gitlab service
1. Create a new project and use the "Import project"
2. Choose "Repo by URL", and fill "https://github.com/pnexpert/exporter-template-gitlab" into the "Git repository URL"
3. Fill in the name in "Project Name" (We suggest to use "exporter-gitlab")
4. Choose the created group in the list of Project Url column
5. Click the "Create project" button

## Retrieve proejct IDs from Pentium Network
1. Contact the Pentium Network to obtain the list of project IDs

## Prepare key pairs
1. Create key pairs ([example](https://docs.gitlab.com/ee/ssh/#generate-an-ssh-key-pair)) and submit public key to Pentium Network through this URL.
2. Store secrets in gitlab (Settings > CI / CD > Variables)
3. Add a variable with setting like, Key: SSH_PRIVATE_KEY_1, Value: the content of private key, Type: File
4. Wait for Pentium Network to notify you all good!

## Prepare the API token
1. Choose / Create an user for the exporter
2. Open the User settings, Access Token
3. Add a personal access token with Name, check the permission of api, read_repository, and write_repository
4. Store secrets in gitlab (Settings > CI / CD > Variables)
5. Add gitlab_user, Key: gitlab_user, Value: id of the user, Type: Variable
6. Add gitlab_token, Key: gitlab_token, Value: <the created token>, type: Variable

## Config your exporter pipeline 
1. Setup a service key with sufficient permissions
2. Create the config file (you can copy the [config.csv-dist](config.csv-dist), rename it to config.csv, and fill your setting in the format: project,ssh_privatE_key_1)
3. Look into the pipeline settings and test it
3. schedule the polling interval for future project updates

Happying syncing!
