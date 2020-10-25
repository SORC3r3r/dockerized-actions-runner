FROM ubuntu:18.04

ENV RUNNER_ALLOW_RUNASROOT=1

WORKDIR /actions-runner

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    tar \
    git \
    iputils-ping \
    sudo \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common \
    gettext \
    build-essential \
    postgresql-client

# update git version
RUN sudo add-apt-repository ppa:git-core/ppa -y \
    && sudo apt-get update \
    && sudo apt-get install git -y


# install docker related tools
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && [[ $(lsb_release -cs) == "eoan" ]] \
    && ( add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu disco stable" ) || ( add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" )\
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli docker-compose pass containerd.io --no-install-recommends

# install kubectl
RUN sudo apt-get update && sudo apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
    && sudo apt-get update \
    && sudo apt-get install -y kubectl

# install kustomize
RUN cd /usr/bin \
    && curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

# install github actions runner
RUN ACTIONS_RUNNER_VERSION=$(git ls-remote --refs --sort="version:refname" --tags https://github.com/actions/runner | cut -d/ -f3-|tail -n1) \
    && ACTIONS_RUNNER_VERSION_NUMBER="${ACTIONS_RUNNER_VERSION:1}" \
    && curl -O -L https://github.com/actions/runner/releases/download/${ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION_NUMBER}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION_NUMBER}.tar.gz \
    && rm -f actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION_NUMBER}.tar.gz

# cleanup
RUN rm -rf /var/lib/apt/lists/*

COPY ./runner.sh ./runner.sh
RUN chmod a+x runner.sh
CMD ["sh", "./runner.sh"]
