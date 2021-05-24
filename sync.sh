# library
. ./lib_gitlab.sh
. ./lib_git.sh

# 0. check if the config.csv exists
if [ ! -f config.csv ]; then
    echo "[ERROR] necessary file: config.csv"
    echo "[ERROR] you can copy config.csv-dist to customize your exporter"
    exit 1
fi

configs=$(cat config.csv)

# fetch project info
harvest_projects
if [ $? != 0 ]; then
  echo "[ERROR] unable to fetch the metadata of projects, please check if the user and token has enough permission"
  exit 1
fi

group_url=$(get_current_group_url)
if [ "${group_url}" == "" ]; then
  echo "[ERROR] the group is belonging to a group or the group info is unavailable, please check if the exporter is in a group"
  exit 1
fi

echo "[DEBUG] group_url: ${group_url}"

for row in ${configs}
do
  repo_name=$(echo "${row}" | awk -F"," '{ print $1 }')
  private_key=$(echo "${row}" | awk -F"," '{ print $2 }')

  # 0. todo: filter the invalid config row

  # 1. check if all repositories exist and all repositories are created by the syncer
  repo_exists_or_create "${repo_name}"
  if [ $? != 0 ]; then
    echo "[ERROR] failed to check repo ${repo_name}" 
    continue
  fi
  echo "[INFO] repo created: ${repo_name}"

  # 2. sync the repositories
  git_sync "${repo_name}" "${private_key}" "${group_url:8}"
  if [ $? != 0 ]; then
    echo "[ERROR] failed to sync ${repo_name}" 
    continue
  fi
  echo "[INFO] repo synced: ${repo_name}"

done

# todo: to have a error collection and show if any errors occurred
