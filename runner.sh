while [[ $(service docker status) != *"Docker is running"* ]]; do service docker start && sleep 5; done
# configure the actions runner and replace existing one with the same name

RUNNER_NAME=${RUNNER_NAME:-"Runner_Without_A_Name"}
RUNNER_REPOSITORY_URL=${RUNNER_REPOSITORY_URL:-"https://github.com"}
RUNNER_TOKEN=${RUNNER_TOKEN:-"Runner_Without_A_Token"}
RUNNER_WORKING_DIRECTORY=${RUNNER_WORKING_DIRECTORY:-"_work"}
RUNNER_LABELS=${RUNNER_LABELS:-"Runner_Without_A_Label"}

./config.sh \
  --name $RUNNER_NAME \
  --url $RUNNER_REPOSITORY_URL \
  --token $RUNNER_TOKEN \
  --work $RUNNER_WORKING_DIRECTORY \
  --labels $RUNNER_LABELS \
  --replace
./run.sh
