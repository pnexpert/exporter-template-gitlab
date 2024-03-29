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

HAS_ERROR=NO

for row in ${configs}
do
  # 0. filter the invalid config row
  if [ "${row}" == "" ]; then
    echo "[INFO] skip: ${row}"
    continue
  fi

  RET=$(echo "${row}" | grep "," | wc -l)
  if [ "${RET}" == 0 ]; then
    echo "[INFO] skip: ${row}"
    continue
  fi

  repo_name=$(echo "${row}" | awk -F"," '{ print $1 }')
  private_key=$(echo "${row}" | awk -F"," '{ print $2 }')

  # 1. check if all repositories exist and all repositories are created by the syncer
  repo_exists_or_create "${repo_name}"
  if [ $? != 0 ]; then
    echo "[ERROR] failed to check repo ${repo_name}" 
    HAS_ERROR=YES
    continue
  fi
  echo "[INFO] repo passed the check: ${repo_name}"

  # 2. sync the repositories
  git_sync "${repo_name}" "${private_key}" "${group_url:8}"
  if [ $? != 0 ]; then
    echo "[ERROR] failed to sync ${repo_name}" 
    HAS_ERROR=YES
    continue
  fi
  echo "[INFO] repo synced: ${repo_name}"

done

# show the errors if any errors occurred
if [ "${HAS_ERROR}" == "YES" ]; then
  echo "[ERROR] One of the sync jobs weng wrong, please search 'ERROR' for the detail"
  exit 1
fi
