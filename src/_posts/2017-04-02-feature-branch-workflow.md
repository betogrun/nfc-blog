---
layout: post
title: "Working with Feature Branch Workflow"
description: "How to use the feature branch workflow with a simple example"
tags: [git]
---

Assuming the project was already initiazed and it is integrated with a remote repository. The following commands show the necessary steps to use the feature branch workflow.

### Create a new branch
{% highlight bash %}
$ git checkout -b new_feature
{% endhighlight %}

### Perform the commits
{% highlight bash %}
touch new_file.txt #Create or modify a file
$ git add new_file.txt
$ git commit -m "Add new file to the project"
{% endhighlight %}

### Push the new branch to origin
{% highlight bash %}
$ git push origin new_feature
{% endhighlight %}

### Operations on Github
1. Go to [https://github.com/your_repository/your_project/branches](https://github.com/your_repository/your_project/branches) and click in "New Pull Request button".
{% include image.html path="post_1/branches_new_pr" path-detail="post_1/branches_new_pr" alt="New PR" %}

2. Create a new Pull Request.
{% include image.html path="post_1/create_pr" path-detail="post_1/create_pr" alt="Create PR" %}


3. Merge the changes in the master branch.
{% include image.html path="post_1/merge_pr" path-detail="post_1/merge_pr" alt="Merge PR" %}

### Update the local master branch
{% highlight bash %}
$ git pull
{% endhighlight %}

Now the changes done in `new_feature` branch are available in the local master.
