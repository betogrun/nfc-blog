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
{% highlight bash %}
$ cURL -u 'YOUR_USER_NAME' https://api.github.com/user/repos -d '{"name":"YOUR_REPOSITORY_NAME"}'
{% endhighlight %}

From the response is possible to get the git url to add a remote and push the changes:
{% highlight bash %}
$ git remote add origin git@github.com:YOUR_USER_NAME/YOUR_REPOSITORY_NAME.git
$ git push origin master
{% endhighlight %}

By default a public repository is created, if you wish to create a private one you need to use:
{% highlight bash %}
$ cURL -u 'YOUR_USER_NAME' https://api.github.com/user/repos -d '{"name":"YOUR_REPOSITORY_NAME", "description":"This is a private repo" "private":"true", }'
{% endhighlight %}

# 2. Adding a alias to git
<br>
It is cumbersome to type the same commands every time, so a git alias make this task pretty straightforward:
{% highlight bash %}
$ git config --global alias.gh-create-repo '!sh -c "cURL -u \"YOUR_USER_NAME\" https://api.github.com/user/repos -d \"{\\\"name\\\":\\\"$1\\\"}\"" -'
{% endhighlight %}


You can generate a [personal access token](https://github.com/settings/tokens/new) and add it to the command above, otherwise cURL will prompt you to enter your password.
{% highlight bash %}
$ git config --global alias.gh-create-repo '!sh -c "cURL -u \"YOUR_USER_NAME:YOUR_TOKEN\" https://api.github.com/user/repos -d \"{\\\"name\\\":\\\"$1\\\"}\"" -'
{% endhighlight %}

From now on you only need to use the alias created above:
{% highlight bash %}
$ git gh-create-repo my_new_repo
$ git remote add origin git@github.com:YOUR_USER_NAME/YOUR_REPOSITORY_NAME.git
$ git push origin master
{% endhighlight %}

It is also possible to enhance the command by making it responsible for add a new remote automatically:
{% highlight bash %}
$ git config --global alias.gh-create-repo '!sh -c "cURL -u \"YOUR_USER_NAME:YOUR_TOKEN\" https://api.github.com/user/repos -d \"{\\\"name\\\":\\\"$1\\\"}\" && git remote add origin git@github.com:YOUR_USER_NAME/$1.git" -'
{% endhighlight %}

Using this option you just need to create the repository and push the changes:
{% highlight bash %}
$ git gh-create-repo my_new_repo
$ git push origin master
{% endhighlight %}

# 3. Using a Ruby Gem
<br>
There are some gems out there that not only make it easy to create repository but to perform all the operations provided by Github API.
- [github-gem](https://github.com/defunkt/github-gem)
- [github-cli](https://github.com/piotrmurach/github_cli)


###### Sources
 - <https://robinwinslow.uk/2013/06/07/create-github-repositories-from-the-command-line/>
 - <http://stackoverflow.com/questions/2423777/is-it-possible-to-create-a-remote-repo-on-github-from-the-cli-without-opening-br/10325316#10325316>
