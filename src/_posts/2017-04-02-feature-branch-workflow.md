---
layout: post
title: "Working with Feature Branch Workflow"
description: "How to use the feature branch workflow with a simple example"
tags: [git]
---

Assuming the project was already initiazed and it is integrated with a remote repository. The following commands show the necessary steps to use the feature branch workflow.

### Create a new branch
```bash
$ git checkout -b new_feature
```

### Perform the commits
```bash
touch new_file.txt #Create or modify a file
$ git add new_file.txt
$ git commit -m "Add new file to the project"
```

### Push the new branch to origin
```bash
$ git push origin new_feature
```

### Operations on Github
1. Go to [https://github.com/your_repository/your_project/branches](https://github.com/your_repository/your_project/branches) and click in "New Pull Request button".
![New PR](/images/post_1/branches_new_pr.png){: .zooming}

2. Create a new Pull Request.
![Create PR](/images/post_1/create_pr.png){: .zooming}


3. Merge the changes in the master branch.
![Merge PR](/images/post_1/merge_pr.png){: .zooming}

### Update the local master branch
```bash
$ git pull
```

Now the changes done in `new_feature` branch are available in the local master.
