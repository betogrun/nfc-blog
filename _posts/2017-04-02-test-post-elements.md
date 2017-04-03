---
layout: post
title: "Working with Feature Branch Workflow"
description: "How to use the feature branch workflow with a simple example"
tags: [git]
---

Assuming the project was already initiazed and it is integrated with a remote repository. The following commands show the necessary steps to use the feature branch workflow.

### Create a new branch
`git checkout -b new_feature`

### Perform the commits
```
touch new_file.txt #Create or modify a file
git add new_file.txt
git commit -m "Add new file to the project"
```

### Push the new branch to origin
`
git push origin new_feature
`

### Github operations
Go to `https://github.com/your_repository/your_project/branches` and click in "New Pull Request button"
Merge the changes in the master branch

## Update the local master branch
`
git pull
`
Now the changes done in new_feature branch are available in the local master.
