function git_sync () {
  repo_name=$1
  private_key_name=$2
  dest_prefix=$3

  # prepare the ssh private key
  eval private_key=\$${private_key_name}
  if [ "${private_key}" == "" ]; then
    echo "[ERROR] private key not set: ${private_key_name}"
    return 1
  fi

  chmod 400 ${private_key}
  # add a newline to prevent from invalid format
  echo "" >> ${private_key}
  ssh-add ${private_key}
  if [ $? != 0 ]; then
    echo "[DEBUG] ssh key ${private_key_name} is in in valid format"
    return 1
  fi

  # verify if the key is correct to the repo
  RET=$(ssh -T git@github.com 2>&1 | grep authenticated | grep "/${repo_name}! ")
  if [ "${RET}" == "" ]; then
    echo "[DEBUG] private key ${private_key_name} can't access ${repo_name}"
    return 1
  fi

  remote=$(git ls-remote git@github.com:pnexpert/${repo_name}.git HEAD | awk '{ print $1 }')
  local=$(git ls-remote https://${gitlab_user}:${gitlab_token}@${dest_prefix}/${repo_name}.git HEAD | awk '{ print $1 }')
  echo "[DEBUG] remote: ${remote}"
  echo "[DEBUG] local: ${local}"

  if [ "${remote}" == "${local}" ]; then
    echo "[DEBUG] skip the sync because ${remote} = ${local}"
    # remove all ssh keys
    ssh-add -D
    return 0
  fi

  # prepare the tmp working folder
  TMP=$(mktemp -d)

  # clone the remote repo
  git clone git@github.com:pnexpert/${repo_name}.git ${TMP}
  if [ $? != 0 ]; then
    echo "[ERROR] failed to fetch remote repo: ${repo_name}"
    return 1
  fi
  # remove all ssh key after cloning to prevent from ssh key conflict
  ssh-add -D

  cd ${TMP}
  git remote add target https://${gitlab_user}:${gitlab_token}@${dest_prefix}/${repo_name}.git

  # push to the local repo
  git push target
  if [ $? != 0 ]; then
    echo "[ERROR] failed to push to local repo: ${repo_name}"
    return 1
  fi

  # go back to the workspace directory
  cd ${CI_PROJECT_DIR}

  # remove the wworking folder of git operations
  rm -Rf ${TMP}
}
