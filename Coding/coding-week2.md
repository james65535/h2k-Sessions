# Coding H2K Session Week 2

This session walks through the use of a version control system such as git, using github, and if time permits an intro to sprints.  The end result should provide a base for how to work on code with others

## What is a Version Control System

A Version Control System or VCS is a way to store project files and capture changes to them over time.  Different VCS exist and handle this capture method in different ways.  Some use delta files to only store differences between changed files, while others store a whole copy of the changed file and use links to users to the different version.

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

1. Fork the repo
2. Clone the fork to your local computer
3. Create your changes to the project
4. Create a branch for your changes
5. Create a pull request
6. Hope the pull request gets accepted!

## Using Sprints to Manage Development Projects

A sprint is an block of time used to work on a project.  A sprint will have a defined set of issues (a piece of work) to be done within this time.  Issues may contain the following info:

- The name of the issue
- Issue priority according to project/product owner or stakeholders
- The description of the work to perform
- The assigned developer
- The state of the issue (if its assigned to a sprint or in the backlog)
- The number of points assigned to a sprint

Multiple sprints are used to work on a project in an interative fashion.  For example a project may have 10 issues created to define what the project should look like when its done.  Two issues can be worked on within the first sprint, three in the second sprint, and five in third sprint.  If an issue is not finished within the assigned sprint then it can be moved to a future sprint.  There are no more sprints when they are no more issues.  If there are no more sprints then a project is "done"!  Compared to the lifespan of a project, a sprint is a short period of time, perhaps two weeks or a month.

The idea is that work takes as long as it takes and we can communicate to stakeholders the cadence for releases so that we can manage expectations.  We look to avoid planning out issues far into the future and instead focus on the near term.

### Using Points

A point system can be used to figure out how many issues can fit in a particular sprint.  It is preferred not to think of points as units of time, an alternative would be measures of complexity.  This will often times be a finger in the air assessment as compared to previous completed work, or if its the very first issue then the points will be quite arbitrary.  The points themselves can be done any number of ways but an easy one is to use the Fibonacci Sequence: 1, 2, 3, 5, 8, 12, etc...  An example:

- To modify the program to accept a command line argument for a config file: 2 points (An easy change)
- To modify the program to read the config file and parse the line items: 5 points (probably twice the level of difficulty as compared to the first issue)
- To modify the program to add a logging facility: 13 points (probably twice the level of difficulty as compared to the second issue)

After multiple sprints have finished, it will be possible to track how many points per sprint have be completed.  This is called sprint velocity.  Hopefully your velocity should be increasing over time as you go from one sprint to the next.  For example:

- Sprint 1: 4pts
- Sprint 2: 5pts
- Sprint 3: 7pts
- Sprint 4: 11pts

Sometimes a issue will be so large it will need to be worked on over several sprints, this is called an Epic.  You can divide Epics into issues so that once all the issues are done, the Epic is done.

### Kanban

There are many ways graphical ways to track issues and assign them as sprints.  Kanban is just one example.  Kanban is a grouping of issues, a typical set of groups may be:

- Backlog (Where issues go when they are first created)
- In Progress (Where issues go when they are being worked on)
- Done (Where issues go when the defined work has been completed)
- Cancelled (Sometimes people decide a particular issue is no longer needed, like when a product owner cancels a feature request)
- Blocked (Where issues go when no more work can occur because of an external dendancy such as another issue being completed or some other reason)

# Relevant links
- http://rogerdudler.github.io/git-guide/
- https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
- https://jwiegley.github.io/git-from-the-bottom-up/

