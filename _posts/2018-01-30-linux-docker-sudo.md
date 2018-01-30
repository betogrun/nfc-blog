---
layout: post
title: "Running docker commands without sudo"
description: "Steps to run docker commands without sudo on Linux"
tags: [docker, linux]
---

# 1. Create a docker group if it doesn't exist
{% highlight bash %}
$ sudo groupadd docker
{% endhighlight %}

# 2. Add the current user to the docker group
{% highlight bash %}
$ sudo usermod -aG docker $USER
{% endhighlight %}

# 3. Restart the docker deamon
{% highlight bash %}
$ sudo service docker restart #Ubuntu
{% endhighlight %}

# 4. Optionally, check you can run docker without sudo
{% highlight bash %}
$ docker run hello-world
{% endhighlight %}

###### Source
 - <https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user>
