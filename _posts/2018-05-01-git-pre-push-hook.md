---
layout: post
title: "Running Rubocop before push"
description: "Setup the pre-push hook to run rubocop before push"
tags: [git, rubocop]
---

Tired of create commits like "Fix rubocop violations" after push your code?<br>
How about run rubocop before each `git push` operation?

### Setup the pre-push hook
Create the file below and save it as `pre-push` in your project's hook directory:<br> `your-project/.git/hooks/`
{% highlight console %}
#!/bin/sh

rubocop
{% endhighlight %}

Then make it executable:
{% highlight console %}
$ chmod +x pre-push
{% endhighlight %}

From now on Rubocop will run before `git push` operation.

### Testing the hook
Make sure you have rubocop installed before proceed.<br>
The push action will be cancelled once a violation is detected, as shown in the example below:

{% highlight console %}
$ git push origin test-branch
Inspecting 41 files
.....C...................................

Offenses:

app/models/user.rb:9:3: C: Layout/LeadingCommentSpace: Missing space after #.
  #another
  ^^^^^^^^
app/models/user.rb:10:1: C: Layout/TrailingWhitespace: Trailing whitespace detected.

41 files inspected, 2 offenses detected
error: failed to push some refs to 'git@github.com:hacker-sessions/remember-the-bills.git'
{% endhighlight %}

After fix the violations you will be able to push the code without problems.

{% highlight console %}
$ git push origin test-branch
Inspecting 41 files
.........................................

41 files inspected, no offenses detected
Counting objects: 11, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (11/11), done.
Writing objects: 100% (11/11), 956 bytes | 0 bytes/s, done.
Total 11 (delta 8), reused 0 (delta 0)
remote: Resolving deltas: 100% (8/8), completed with 4 local objects.
To git@github.com:hacker-sessions/remember-the-bills.git
 * [new branch]      test-branch -> test-branch
{% endhighlight %}

###### Sources
 - <https://git-scm.com/book/uz/v2/Customizing-Git-Git-Hooks>
 - <https://youtu.be/BZbW8FAvf00?t=23m34s>
 - <http://gmodarelli.com/2015/01/code_reviews_rubocop_pre_commit/>
