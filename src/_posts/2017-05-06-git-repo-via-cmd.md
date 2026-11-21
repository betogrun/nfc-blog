---
layout: post
title: "Creating a Github repository from CLI"
description: "How to initialize a github repo using the Github API"
tags: [git, github]
---

Whenever I'm creating a new project from console I always need to leave it and go to github webpage to create a new repository and come back to console to push the changes.<br>
There some ways to create the repository via CLI.

# 1. Via cURL
<br>
By using the github API and cURL it is really easy to create a new repository:
```bash
$ cURL -u 'YOUR_USER_NAME' https://api.github.com/user/repos -d '{"name":"YOUR_REPOSITORY_NAME"}'
```

From the response is possible to get the git url to add a remote and push the changes:
```bash
$ git remote add origin git@github.com:YOUR_USER_NAME/YOUR_REPOSITORY_NAME.git
$ git push origin master
```

By default a public repository is created, if you wish to create a private one you need to use:
```bash
$ cURL -u 'YOUR_USER_NAME' https://api.github.com/user/repos -d '{"name":"YOUR_REPOSITORY_NAME", "description":"This is a private repo" "private":"true", }'
```

# 2. Adding a alias to git
<br>
It is cumbersome to type the same commands every time, so a git alias make this task pretty straightforward:
```bash
$ git config --global alias.gh-create-repo '!sh -c "cURL -u \"YOUR_USER_NAME\" https://api.github.com/user/repos -d \"{\\\"name\\\":\\\"$1\\\"}\"" -'
```


You can generate a [personal access token](https://github.com/settings/tokens/new) and add it to the command above, otherwise cURL will prompt you to enter your password.
```bash
$ git config --global alias.gh-create-repo '!sh -c "cURL -u \"YOUR_USER_NAME:YOUR_TOKEN\" https://api.github.com/user/repos -d \"{\\\"name\\\":\\\"$1\\\"}\"" -'
```

From now on you only need to use the alias created above:
```bash
$ git init
$ git gh-create-repo my_new_repo
$ git remote add origin git@github.com:YOUR_USER_NAME/YOUR_REPOSITORY_NAME.git
$ git push origin master
```

It is also possible to enhance the command by making it responsible for add a new remote automatically:
```bash
$ git config --global alias.gh-create-repo '!sh -c "cURL -u \"YOUR_USER_NAME:YOUR_TOKEN\" https://api.github.com/user/repos -d \"{\\\"name\\\":\\\"$1\\\"}\" && git remote add origin git@github.com:YOUR_USER_NAME/$1.git" -'
```

Using this option you just need to create the repository and push the changes:
```bash
$ git init
$ git gh-create-repo my_new_repo
$ git push origin master
```

PS: For a silent output you can use: `cURL -s -o /dev/null`

# 3. Using a Ruby Gem
<br>
There are some gems out there that not only make it easy to create repository but to perform all the operations provided by Github API.
- [github-gem](https://github.com/defunkt/github-gem)
- [github-cli](https://github.com/piotrmurach/github_cli)


###### Sources
 - <https://robinwinslow.uk/2013/06/07/create-github-repositories-from-the-command-line/>
 - <http://stackoverflow.com/questions/2423777/is-it-possible-to-create-a-remote-repo-on-github-from-the-cli-without-opening-br/10325316#10325316>
