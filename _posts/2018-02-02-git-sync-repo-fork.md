---
layout: post
title: "Syncing a fork"
description: "Updating a local repository with upstream changes"
tags: [git, github]
---

Atention: Make sure you have a configured remote pointing to the remote upstream.

#### 1. Fetch branches and commits from upstream
{% highlight console %}
$ git fetch upstream 

remote: Counting objects: 6, done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 6 (delta 1), reused 0 (delta 0), pack-reused 1
Unpacking objects: 100% (6/6), done.
From github.com:hacker-sessions/mySelfie
   7e5e502..588a4df  master     -> upstream/master

{% endhighlight %}

#### 2. Make sure to checkout to your fork's local brach
{% highlight console %}
$ git checkout master

Switched to branch 'master'
{% endhighlight %}

#### 3. Merge changes from `upstream/master` to local master
{% highlight console %}
$ git merge upstream/master

Updating 7c208d3..588a4df
Fast-forward
 Dockerfile                             | 37 +++++++++++++
 Procfile.dev                           |  2 +-
 README.md                              | 13 ++++-
 app/javascript/packs/tag/Tag.vue       | 38 +++++++++++++
 app/javascript/packs/tag/hello.js      | 19 +++++++
 app/views/layouts/application.html.erb |  1 -
 app/views/pages/index.html.erb         |  3 ++
 config/database.yml                    |  2 +
 docker-compose.yml                     | 21 ++++++++
 package.json                           |  1 +
 yarn.lock                              | 98 ++++++++++++++++++++++++++++++++--
 11 files changed, 228 insertions(+), 7 deletions(-)
 create mode 100644 Dockerfile
 create mode 100644 app/javascript/packs/tag/Tag.vue
 create mode 100644 app/javascript/packs/tag/hello.js
 create mode 100644 docker-compose.yml

{% endhighlight %}

PS: It is still necessary to push these changes to your fork on Github.

###### Source
 - <https://help.github.com/articles/syncing-a-fork/>
