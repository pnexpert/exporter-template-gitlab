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
  ssh-add ${private_key}
  ssh -T git@github.com

  # prepare the tmp working folder
  TMP=$(mktemp -d)
  # todo: a check to clarify if the ssh key is correct to the repo

  # clone the remote repo
  git clone git@github.com:pnetwork/${repo_name}.git ${TMP}
  if [ $? != 0 ]; then
    echo "[ERROR] failed to fetch remote repo: ${repo_name}"
    return 1
  fi
  # remove all ssh key after cloning to prevent from ssh key conflict
  ssh-add -D

  cd ${TMP}
  git remote add target https://${gitlab_user}:${gitlab_token}@${dest_prefix}/${repo_name}.git

  # push to the local repo
  git push target main:master
  if [ $? != 0 ]; then
    echo "[ERROR] failed to push to local repo: ${repo_name}"
    return 1
  fi

  # go back to the workspace directory
  cd ${CI_PROJECT_DIR}

  # remove the wworking folder of git operations
  rm -Rf ${TMP}
}
