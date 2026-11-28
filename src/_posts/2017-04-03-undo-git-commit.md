---
layout: post
title: "How to undo a commit"
description: "Steps to undo the last commit"
tags: [git]
---

Sometimes we realize that a problematic file was added and committed by mistake, others we just commit the right files in the wrong branch.
For these cases we can easily undo the commit following the example below:

Some file is modified:

```console?prompt=$
$ echo "something wrong here" >> new_file.txt
```

The change is committed:

```console?prompt=$
$ git commit -m "Something wrong!"
```

After realizing the mistake, use the following command:

```console?prompt=$
$ git reset HEAD~
Unstaged changes after reset:
M	new_file.txt
```

The changes will be unstaged:

```console?prompt=$
$ git status
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   new_file.txt

no changes added to commit (use "git add" and/or "git commit -a")
```
