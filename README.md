# Polling / sync projects to your gitlab server 
This Gitlab CICD pipeline template for you to config which projects to be synced to your own gitlab server using CICD pipeline

# Prerequsite 
This project assumes you've been familiar with:
1. Setup gitlab CICD pipeline
2. Manage secrets in gitlab 
3. Basic git operations

# Sync projects

## Create a group in your gitlab service
1. 建立一個存放 exporter 跟同步來的專案的 group
## Clone the projects to your gitlab service
1. 新增一個專案，點選 "Import project" 匯入
2. 選擇 "Repo by URL", and 在 "Git repository URL" 欄位裡面填入 "https://github.com/pnexpert/exporter-template-gitlab" 
3. "Project Name" 欄位裡面填入專案名稱 (我們建議使用 exporter-gitlab)
4. 在 "Project Url" 裡面的選單裡面，選擇剛剛建立的 group
5. 按下 "Create project" 按鈕開始匯入

## Retrieve proejct IDs from Pentium Network
1. Contact the Pentium Network to obtain the list of project IDs

## Prepare key pairs
1. Create key pairs ([範例](https://docs.gitlab.com/ee/ssh/#generate-an-ssh-key-pair)) and submit public key to Pentium Network through this URL.

<pre>ssh-keygen -t ed25519 -C "sync [要 sync 的專案名稱]"</pre>

2. Store secrets in gitlab (Exporter 專案的 Settings > CI / CD > Variables)
3. 新增 variable，內容為:

<pre>
Key: SSH_PRIVATE_KEY_[流水號]
Value: [private key 的檔案內容]
Type: File
</pre>

4. Wait for Pentium Network to notify you all good!

## Prepare the API token
1. 選擇或建立一個使用者，exporter 會以該使用者的全縣運作
2. 打開使用者的 User settings > Access Token
3. 新增一個 personal access token，內容會包含:

<pre>
Name: token 名稱 (可以寫 exporter 用)
勾選權限:
api, read_repository, and write_repository
</pre>

4. Store secrets in gitlab (Settings > CI / CD > Variables)
5. 新增 variable，內容為:

<pre>
Key: gitlab_user
Value: id of the user
Type: Variable
</pre>

6. 新增 gitlab_token 的 variable，內容為:

Add gitlab_token, Key: gitlab_token, Value: <the created token>, type: Variable

## Config your exporter pipeline 
1. Setup a service key with sufficient permissions
2. Create the config file (you can copy the [config.csv-dist](config.csv-dist), rename it to config.csv, and fill your setting in the format: project,ssh_privatE_key_1)
3. Look into the pipeline settings and test it
3. schedule the polling interval for future project updates

Happying syncing!
