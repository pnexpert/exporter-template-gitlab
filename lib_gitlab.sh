function harvest_projects () {
  curl --header "Authorization: Bearer ${gitlab_token}" ${CI_API_V4_URL}/projects > ${CI_PROJECT_DIR}/projects.json
}

function get_current_group_url () {
  cat ${CI_PROJECT_DIR}/projects.json | jq -r '.[] | select (.web_url=="'${CI_PROJECT_URL}'") | .namespace.web_url' |  sed 's#/groups/#/#g'
}

function create_a_project () {
  repo_name=$1

  _group_id=$(cat ${CI_PROJECT_DIR}/projects.json | jq -r '.[] | select (.web_url=="'${CI_PROJECT_URL}'") | .namespace.id')
  curl --header "Authorization: Bearer ${gitlab_token}" -X POST "${CI_API_V4_URL}/projects?name=${repo_name}&namespace_id=${_group_id}"
}

function project_exists () {
  repo_name=$1

  _group_id=$(cat ${CI_PROJECT_DIR}/projects.json | jq -r '.[] | select (.web_url=="'${CI_PROJECT_URL}'") | .namespace.id')

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
