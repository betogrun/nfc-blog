---
layout: post
title: "Docker setup for Rails and Vue.js"
description: "Running a Rails with Vue.js application with docker"
tags: [docker, rails, vue]
---

Since Rails 5.1 it is possible to create applications with modern javascript frameworks like Angular, React and Vue.js.

The example bellow ilustrate how to create the Dockerfile and the docker-compose.yml in order to get an exisisting Rails and Vue.js application running in a conatiner.

# Dockerfile
{% highlight dockerfile %}
FROM ruby:2.4.1

# Set install path
ENV INSTALL_PATH /usr/src/app

# Install dependencies
RUN apt-get update && apt-get install -y build-essential libpq-dev

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install nodejs

# Install yarn
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Fix: 'Cannot find module 'node-sass'
RUN yarn add node-sass

# Create the main directory
RUN mkdir $INSTALL_PATH

# Set the main directory to INSTALL_PATH
WORKDIR $INSTALL_PATH

# Install gems
ADD Gemfile $INSTALL_PATH/Gemfile
ADD Gemfile.lock $INSTALL_PATH/Gemfile.lock
RUN bundle install

# Install foreman
RUN gem install foreman

# Copy the code to the container
COPY . .
{% endhighlight %}

# docker-compose.yml
{% highlight yaml %}
version: '2'

services:
  postgres:
    image: 'postgres:9.5'
    volumes:
      - 'postgres:/var/lib/postgresql/data'

  website:
    depends_on:
      - 'postgres'
    build: .
    command: foreman start -f Procfile.dev
    ports:
      - '5000:5000'
      - '8080:8080'
    volumes:
      - '.:/usr/src/app'

volumes:
  postgres:
{% endhighlight %}

The commands bellow assumes you have docker installed:


{% highlight console %}
$ docker-compose build
$ docker-compose run --rm web bin/setup
$ docker-compose up
{% endhighlight %}

Access: <http://localhost:5000>

Application used in this example: <https://github.com/hacker-sessions/mySelfie>

###### Source
 - <https://tackeyy.com/blog/posts/run-rails-and-vuejs-on-docker-container>
