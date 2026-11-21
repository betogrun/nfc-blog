---
layout: post
title: "asdf: No version set for command bundle"
description: "How to solve the 'No version set for command bundle' asdf error"
tags: [ruby, rails, asdf]
---

[ASDF](https://github.com/asdf-vm/asdf) is a very interesting version manager with support for several programming languages through [plugins](https://asdf-vm.com/#/plugins-all).

This post shows a strange behavior I faced when I tried to use an old Ruby version in a Ruby on Rails application.

# Installation

I installed Ruby 2.4.3 and set it locally without problems:

{% highlight console %}
$ asdf install ruby 2.4.3
$ asdf local ruby 2.4.3

$ ruby -v
ruby 2.4.3p205 (2017-12-14 revision 61247) [x86_64-linux]
{% endhighlight %}

# Error

Everything seemed fine until I try to install the gems for this version:

{% highlight console %}
$ bundle install
asdf: No version set for command bundle
you might want to add one of the following in your .tool-versions file:
ruby 2.6.1
ruby 2.6.3
{% endhighlight %}

Checking the `.tool-versions`  file also displayed the expected version:

{% highlight console %}
$ cat .tool-versions
ruby 2.4.3
{% endhighlight %}

# Solution

After some research, I found similar issues on Github but suggestions like run `asdf reshim ruby` and "restart the terminal" didn't work.<br>
The actual problem was the message provided by asdf was not clear enough as pointed in this [answer](https://github.com/asdf-vm/asdf-ruby/issues/127#issuecomment-537952548).

I wasn't able to run `bundle install` because I didn't have bundler for this Ruby version.<br>
Installing bundler solved the issue:

{% highlight console %}
$ gem install bundler
{% endhighlight %}

###### Source
 - <https://github.com/asdf-vm/asdf-ruby/issues/127>
 - <https://github.com/asdf-vm/asdf/issues/557>

