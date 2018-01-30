---
layout: post
title: "How to undo a commit"
description: "Steps to undo the last commit"
tags: [git]
---

Sometimes we realize that a problematic file was added and commited by mistake, others we just commit the right files in the wrong branch.
For these cases we can easely undo the commit following the example bellow:

{% highlight bash %}
#Some file is modified
echo "something wrong here" >> new_file.txt
#The change is commited
$ git commit -m "Something wrong!"
#After realize the mistake, use the follwing commmand:
$ git reset HEAD~
Unstaged changes after reset:
M	new_file.txt
{% endhighlight %}

The changes will be unstaged:
{% highlight bash %}
$ git status
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   new_file.txt

no changes added to commit (use "git add" and/or "git commit -a")
{% endhighlight %}
