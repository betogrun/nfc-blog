---
layout: post
title: "Running docker commands without sudo"
description: "Steps to run docker commands without sudo on Linux"
tags: [docker, linux]
---

#### 1. Create a docker group if it doesn't exist
```bash
$ sudo groupadd docker
```

#### 2. Add the current user to the docker group
```bash
$ sudo usermod -aG docker $USER
```

#### 3. Restart the docker deamon
```bash
$ sudo service docker restart #Ubuntu
```

#### 4. Optionally, check you can run docker without sudo
```bash
$ docker run hello-world
```

###### Source
 - <https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user>
