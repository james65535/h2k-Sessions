# Coding H2K Session Week 2

This session walks through the use of a version control system such as git, using github, and if time permits an intro to sprints.  The end result should provide a base for how to work on code with others.

## What is a Version Control System

A Version Control System or VCS is a way to store project files and capture changes to them over time.  Different VCS exist and handle this capture method in different ways.  Some use delta files to only store differences between changed files, while others store a whole copy of the changed file and use links to direct users to different versions.

An example of creating a file with some text, modiyfing it, then accessing the original file contents:

```
-- echo "hello" > fileA.txt
-- git add fileA.txt
-- git commit -m "first commit"
-- echo "hello 2" > fileA.txt
-- git commit -m "second commit"
-- git log
-- git checkout <checksum>
-- cat fileA.txt
-- git checkout master
```

## Differences Between Centralised and Distributed VCS

- A repository existing in a single place versus a repository which can exist in many places at once such as developer desktops
- Can be great working against a local copy of a repository if offline or on a slow network
- A distributed VCS may not be greated for large binaries as it does not store them efficiently

## Using Git

Git is a DVCS and the following examples will show basic functionality.

### The Basics

When working within a repository; the contents will exist in a certain state:

- Working/Modified (the state your file is in when you're actively creating/modiyfing it)
- Staged (When you are done with your file and you want to prepare a new update by adding the file to it)
- Commited (To finally confirm your update to the repository)

To create a git repository:

```
mkdir testRepo && cd testRepo
git init
```

Git will create a hidden directory to store information about your repository:
```
ls -lta
ls .git
```

Important Files/Folders:

- config: (a configuration file to store how you want your repo configured, there can be other config files such as a global config)
- HEAD: a link to a branch
- hooks: (a place for scripts which will run on state transitions similar to vRO)
- objects: (Where the compressed snapshots of your commits exist)

Basic Operations

To save a snapshot of a file:
```
# Stage the changed file
git add <filename> # or to add all files: git add -a 
# to create a snapshot of a file
git commit -m "insert commit message here"
# Optional command to push changes to another repository like github
git push -u origin master
```

To work with a particular snapshot:
```
# To see the list of commits
git log
# To work on a particular commit
git checkout <commit id>
# To revert back to the latest commit
git checkout master
``` 

### Git Branching

Think of the commit timeline of a repository as a tree.  We start off with the trunk and over time the trunk may split off into seperate "branches" where we will have multiple commit timelines existing simultaneously.  Sometimes you will want to create branches to work on a set of files over a prolonged period of time while keeping an option open to work on the same set but with other changes.  For example, some reasons for branching:

- A Feature Branch or Development Branch
- A Fix Branch

Some terms:

- Branch: A split from the current commit timeline
- Master: The default branch when a repo is created
- Tip: The last commit in a branch
- Head: A reference to the currently checked out commit, when head is not the tip of a branch it is considered detatched
- Merge: To bring a commit from one branch into another
- Rebase: Replacing the commit history of one branch with another

To create a new branch:

```
git checkout -b <branchname>
# create changes
git add -A
git commit -m "<commit message>"
# Optional if using a remote like github
git push -u origin <branch name>
```

### Working with Others

With a DVCS, for when multiple users want to work together, there are a number of options available.

- Remote: A location on a network to another copy of the repository
- Origin: The upstream remote
- Fork: Creates a local copy of a repository so you don't have to work directly with the initial repository

To add an existing local repo to GitHub:

1. Create repo on github
2. Execute the following commands on the local machine:

```
git remote add origin https://github.com/<username>/<reponame>.git
git push -u origin master
```

If you want to work on a public repo which is not your own, the common process is:

1. On github go to the desired repo and select fork
2. Clone the fork to your local computer
3. Create your changes to the project (for future changes be sure to always pull down the most up to date changes before you work!)
4. Add your changes and commit them
5. Pull down a fresh copy from github if other people have been working on your fork
6. Create a branch for your changes
7. Push your changes to github
8. Create a pull request from the github page for your fork
9. The repo admins will review your request, merge the changed, deny them, or provide further instructions

Sometimes you'll want to ditch your latest commits and pull in a fresh copy from a remote:

```
git fetch origin
git reset --hard origin/master
```

# Relevant links
- http://rogerdudler.github.io/git-guide/
- https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
- https://jwiegley.github.io/git-from-the-bottom-up/
- https://learngitbranching.js.org/

