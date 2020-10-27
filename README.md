# dockerized-actions-runnner

The `dockerized-actions-runner` enables you to host your self-hosted Github actions runner in a Docker container.

Based on `Ubuntu 18.04` it has a limited set of tools installed. (see `./Dockerfile`)

It was designed to enable Docker-In-Docker workflow runs. That means as long as you build every step in your own action
in or with your own container, you can use the `dockerized-actions-runner` self-hosted runner. The Docker container in
which the Github actions runner is running has some standard tooling as well. 
If you need to add other tools to use in your action workflow, use the Docker image as your base image and additionally
install the tools you need.

## Build status

![build and publish](https://github.com/SORC3r3r/dockerized-actions-runner/workflows/build%20and%20publish/badge.svg)

## Configure

Docker environment variable configuration:

Name | Description | Required | Default
------------ | ------------- | ------------- | -------------
RUNNER_NAME | Set a name for your runner | false | `Runner_Without_A_Name`
RUNNER_REPOSITORY_URL | URL of your Github repository | true | -
RUNNER_TOKEN | Your runner token | true | -
RUNNER_WORKING_DIRECTORY | Runners working directory inside the container | false | `_work`
RUNNER_LABELS | Comma separated list of runner labels | false | `Runner_Without_A_Label`

:information_source: :information_desk_person:

To get your `RUNNER_TOKEN`, go to `YourRepository -> Settings -> Actions` and selet `Add runner`. This will pop up some 
instructions on how to add a self-hosted runner. The instructions contain a token, just copy it and use it here. 

## Run

To simply run the `dockerized-actions-runner` execute:
```
docker run \
  --privileged \
  -e "RUNNER_NAME=my-actions-runner-running-in-docker" \
  -e "RUNNER_REPOSITORY_URL=https://github.com/sorc3r3r/dockerized-actions-runner" \
  -e "RUNNER_TOKEN=<YOUR_RUNNER_TOKEN>" \
  -e "RUNNER_WORK_DIRECTORY=_work" \
  -e "RUNNER_LABELS=dockerized,my-runner" \
  docker.pkg.github.com/sorc3r3r/dockerized-actions-runner/dockerized-actions-runner:latest
```

You can also update and use the `docker-compose.yml` located in `./templates/sorc3r3r/docker-compose.yml`

## Deploying multiple runners at once

To conveniently launch multiple actions runner, you can use the `launch.sh` script.

```
Usage: ./launch.sh [options [parameters]]

Options:
  Required:
  -o : owner, Owner of GitHub repository
  -r : repository, GitHub repository (not required if you want to launch org runners)
  -a : auth-token, GitHub personal access token
  Optional:
  -p : path, optional - Path to save the generated docker-compose files to; defaults to ./.dockerized_actions_runner
  -t : runner-type, Choose to create an repository or org level runner; Options:[repo/org], defaults to [repo]
  -c : count, Number of runners to be launched; defaults to [1]
  -n : name, Desired name of your runner
```

```
Examples:

Launch 3 action runners for the repository 'dockerized-actions-runner' of 'SORC3r3r' with a custom name "my-runner-in-docker"
./launch.sh -o sorc3r3r -r dockerized-actions-runner -a 92hoifu4o7ro38z48bfzbw9er4h8bf8oz3b -c 3 -n my-runner-in-docker

Launch 5 organisation level runners for organisation 'sorc3r3r-org'
./launch.sh -t org -o sorc3r3r-org -a 92hoifu4o7ro38z48bfzbw9er4h8bf8oz3b -c 5

# In case of the org level runner, you need to have admin access to the organisation and your access token has to 
inherit those access rights
```

The `launch.sh` script will use your `GitHub personal access token` to fetch the `RUNNER_TOKEN` for whatever number of 
runners you want to deploy. 

You can either launch runners on repository level or on organisation level. By default, the script will try to create a
repository level runners. Only if you provide the runner type `-t org`, it will create organisation level runners.

:warning:

Depending on the runner-type, you need different access token rights.

Repository Level Runner:
* should have full repository rights checked (`repo`)

Organisation level runner:
* check the admin organisation access rights (`admin:org`)

The `GitHub personal access token` should have full repository rights checked.

[Creating a personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token#using-a-token-on-the-command-line)
