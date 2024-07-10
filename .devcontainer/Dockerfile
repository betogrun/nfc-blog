FROM debian:buster

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Set default versions for Ruby and Node.js
ARG RUBY_VERSION=2.4.3
ARG NODE_VERSION=10

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user para detalhes.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install basic dependencies
RUN apt-get update \
  && apt-get -y install --no-install-recommends apt-utils dialog locales 2>&1 \
  && apt-get -y install git openssh-client iproute2 procps lsb-release curl software-properties-common sudo \
  && apt-get -y install build-essential libssl-dev libreadline-dev zlib1g-dev libyaml-dev libffi-dev \
  && apt-get -y install autoconf bison libgdbm-dev libncurses5-dev libtool libgmp-dev \
  #
  # Set the locale
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_US.UTF-8 \
  #
  # Clean up
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8

# Install Ruby
RUN curl -sSL https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-$RUBY_VERSION.tar.gz | tar -xz \
  && cd ruby-$RUBY_VERSION \
  && ./configure \
  && make \
  && make install \
  && cd .. \
  && rm -rf ruby-$RUBY_VERSION \
  #
  # Install Bundler
  && gem install bundler -v 2.2.31 \
  #
  # Install ruby-debug-ide and debase
  && gem install ruby-debug-ide \
  && gem install debase

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
  && apt-get install -y nodejs \
  #
  # Clean up
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y yarn \
  #
  # Clean up
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user to use if preferred
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # Add sudo support for the non-root user
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the default user
USER vscode

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
