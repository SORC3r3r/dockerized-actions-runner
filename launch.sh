#!/usr/bin/env bash

function show_usage (){
    printf "Usage: $0 [options [parameters]]\n"
    printf "\n"
    printf "Options:\n  Required:\n"
    printf "  -o : owner, Owner of GitHub repository\n"
    printf "  -r : repository, GitHub repository (not required if you want to launch org runners)\n"
    printf "  -a : auth-token, GitHub personal access token\n"
    printf "  Optional:\n"
    printf "  -p : path, optional - Path to save the generated docker-compose files to; defaults to ./.dockerized_actions_runner\n"
    printf "  -t : runner-type, Choose to create an repository or org level runner; Options:[repo/org], defaults to [repo]\n"
    printf "  -c : count, Number of runners to be launched; defaults to [1]\n"
    printf "  -n : name, Desired name of your runner\n"
exit 1
}

function create_runner_directory (){
  if [ $RUNNER_TYPE == 'repo' ]; then
    echo "Creating directory $RUNNER_PATH/$GITHUB_OWNER/$GITHUB_REPOSITORY"
    mkdir -p $RUNNER_PATH/$GITHUB_OWNER/$GITHUB_REPOSITORY
    GITHUB_URL="https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPOSITORY/actions/runners/registration-token"
    COMPOSE_PATH=$RUNNER_PATH/$GITHUB_OWNER/$GITHUB_REPOSITORY
  elif [ $RUNNER_TYPE == 'org' ]; then
    echo "Creating directory $RUNNER_PATH/$GITHUB_GITHUB_ORG"
    mkdir -p $RUNNER_PATH/$GITHUB_GITHUB_ORG
    GITHUB_URL="https://api.github.com/orgs/$GITHUB_GITHUB_OWNER/actions/runners/registration-token"
    COMPOSE_PATH=$RUNNER_PATH/$GITHUB_GITHUB_OWNER
  else
    show_usage
  fi
}

while getopts a:o:r:p:t:c:n: option
do
case "${option}"
in
o) GITHUB_OWNER=${OPTARG};;
r) GITHUB_REPOSITORY=${OPTARG};;
a) GITHUB_AUTH_TOKEN=${OPTARG};;
p) RUNNER_PATH=${OPTARG};;
t) RUNNER_TYPE=${OPTARG};;
c) RUNNER_COUNT=${OPTARG};;
n) RUNNER_CUSTOM_NAME=${OPTARG};;
*) show_usage;;
esac
done

RUNNER_PATH=${RUNNER_PATH:-'./.dockerized_actions_runner'}
RUNNER_TYPE=${RUNNER_TYPE:-'undefined'}
RUNNER_CUSTOM_NAME=${RUNNER_CUSTOM_NAME:-'dockerized-actions-runner'}
RUNNER_COUNT=${RUNNER_COUNT:-1}
create_runner_directory

for ((i = 1 ; i <= $RUNNER_COUNT ; i++)); do
  GITHUB_RUNNER_TOKEN=$(curl --location --request POST \
  $GITHUB_URL \
  --header "Authorization: Bearer $GITHUB_AUTH_TOKEN" \
  | jq -r '.token')

  echo "Runner token: $GITHUB_RUNNER_TOKEN"
  if [ $i == 1 ]; then
    sed -e "s/GITHUB_RUNNER_TOKEN/$GITHUB_RUNNER_TOKEN/g" \
      -e "s/RUNNER_CUSTOM_NAME/$RUNNER_CUSTOM_NAME-$i/g" \
      -e "s/GITHUB_OWNER/$GITHUB_OWNER/g" \
      -e "s/GITHUB_REPOSITORY/$GITHUB_REPOSITORY/g" \
      .helper/base.yml >> $COMPOSE_PATH/docker-compose.yml
  elif [ $i \> 1 ]; then
    sed -e "s/GITHUB_RUNNER_TOKEN/$GITHUB_RUNNER_TOKEN/g" \
      -e "s/RUNNER_CUSTOM_NAME/$RUNNER_CUSTOM_NAME-$i/g" \
      -e "s/GITHUB_OWNER/$GITHUB_OWNER/g" \
      -e "s/GITHUB_REPOSITORY/$GITHUB_REPOSITORY/g" \
      .helper/add.yml >> $COMPOSE_PATH/docker-compose.yml
  fi
  # Make sure you don't fetch the same runner token twice
  sleep 1
done

# Launch dockerized-actions-runner
docker-compose -f $COMPOSE_PATH/docker-compose.yml up
