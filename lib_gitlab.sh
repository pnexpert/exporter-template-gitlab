function harvest_projects () {
  curl --header "Authorization: Bearer ${gitlab_token}" ${CI_API_V4_URL}/projects > ${CI_PROJECT_DIR}/projects.json
  if [ $? != 0 ]; then
    echo "[DEBUG] failed to fetch metadata of projects"
    return 1
  fi
  
  # to verify the output is json: [{"name": "something"}]
  cat ${CI_PROJECT_DIR}/projects.json | jq '.[] | .name' > /dev/null
  if [ $? != 0 ]; then
    echo "[DEBUG] invalid metadata format"
    return 1
  fi

  # todo: to verify the output includes the exporter project and can read private projects
}

function get_current_group_url () {
  # filter: .namespace.kind==group: repo is belonging to a group
  # filter: web.url meets the input
  group_url=$(cat ${CI_PROJECT_DIR}/projects.json | jq -r '.[] | select (.namespace.kind=="group") | select (.web_url=="'${CI_PROJECT_URL}'") | .namespace.web_url' | sed 's#/groups/#/#g')
  
  echo "${group_url}"
}

function create_a_project () {
  repo_name=$1

  _group_id=$(cat ${CI_PROJECT_DIR}/projects.json | jq -r '.[] | select (.namespace.kind=="group") | select (.web_url=="'${CI_PROJECT_URL}'") | .namespace.id')
  if [ "${_group_id}" == "" ]; then
    echo "[DEBUG] group id is unavailable"
    return 1
  fi

  # call the create repo API
  json=$(curl --header "Authorization: Bearer ${gitlab_token}" -X POST "${CI_API_V4_URL}/projects?name=${repo_name}&namespace_id=${_group_id}")

  # check if the creating succeeded
  _name=$(echo "${json}" | jq 'select(.name=="'${repo_name}'") | .name')
  if [ "${_name}" == "" ]; then
    echo "[DEBUG] failed to create ${repo_name}"
    return 1
  else
    return 0
  fi
}

function project_exists () {
  repo_name=$1

  _group_id=$(cat ${CI_PROJECT_DIR}/projects.json | jq -r '.[] | select (.namespace.kind=="group") | select (.web_url=="'${CI_PROJECT_URL}'") | .namespace.id')
  if [ "${_group_id}" == "" ]; then
    echo "[DEBUG] group id is unavailable"
    return 1
  fi

  RET=$(cat ${CI_PROJECT_DIR}/projects.json | jq -r '.[] | select (.name=="'${repo_name}'") | select (.namespace.id=='"${_group_id}"') | .id ' | wc -l)
  if [ "${RET}" == "0" ]; then
    return 1
  else
    return 0
  fi
 }

function repo_exists_or_create () {
  repo_name=$1

  project_exists "${repo_name}"
  if [ $? == 0 ]; then
    return 0
  fi

  create_a_project "${repo_name}"
  return $?
  if [ $? != 0 ]; then
    echo "failed to create a new repo: ${repo_name}"
    return 1
  fi

}
