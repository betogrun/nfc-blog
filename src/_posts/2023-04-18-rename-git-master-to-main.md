---
layout: post
title: "Renaming the default Git branch to main"
description: "How to change the default Git branch from master to main"
tags: [git, github]
---

### Introduction
Several companies, including Microsoft, GitHub, and Gitlab, decided to rename the "master" branch in Git to "main".  This change was a response to a movement that aims to eliminate harmful and exclusionary language while promoting inclusivity and respect in the industry.

This post provides a simple guide for how to rename the branch in your own Git repositories.

### How to rename the master branch to main in Git

First we need to rename the master branch to main using the command below:

```console
 git branch --move master main
```

Then we need to push the main branch to the remote repository

```console
git push -u origin main
```

Now it is necessary to let GitHub know that "main" is the new default branch for this repo.

Access your repository and navigate to the "Settings" page.
In the "Default Branch" section, click on the "Switch" button.

![Default branch](/images/documentation/post_18_4_23_1.png){: .zooming}
Select the 'main' branch from the dropdown menu and click on "Update".

![Default branch](/images/documentation/post_18_4_23_2.png){: .zooming}
A warning message will appear. Click on "I understand, update this branch" to confirm the action.

![Default branch](/images/documentation/post_18_4_23_3.png){: .zooming}

### How to change the default branch for new projects

Starting with Git version 2.28, you can define the default branch name for new projects. To ensure that you have a compatible version of Git, make sure that your Git version is at least 2.28.

Once you have confirmed your Git version, you can use the following command to set 'main' as the default branch for all new Git repositories:

```console
git config --global init.defaultBranch main
```

### Summary

To sum up, the decision to rename the "master" branch to "main" is a step towards creating a more equitable and respectful tech culture. By following the simple guide provided in this post, we can contribute to make the tech industry a more welcoming place for everyone.
	
#### References

- <https://github.com/github/renaming>
- <https://github.blog/2020-07-27-highlights-from-git-2-28/#introducing-init-defaultbranch>
- <https://dev.to/lukeocodes/change-git-s-default-branch-from-master-19le>
