# Working on Development Projects with Others

Working on complicated actions such as software development and gopher shaving usually necessitates a certain level of cooperation amongst the people involved.  A good way to cooperate is to set and manage expectations, nobody likes unexpected occurences, especially while de-hairing a small rodent.

This week's tutorial will work through how to track the progress of a development project and also how to automate laborious tasks in order to speed up process for releasing stable software.

We'll leave the gophers for another time...

## A Note on Agile

Agile is a culture based upon certain values, much in the same way that DevOps is a cultural movement.  Its not possible to have a Agile/DevOps team, or buy an Agile/DevOps tool, or even be Agile/DevOps certified.  However, you can create processes which embody the values of these cultures and automate them using tools where the action of doing so provides value.  The following Twelve Principles are from the Agile Manifesto and will give a reasonable overview of the cultural values.  Note, principles listed here in compressed form:

- Satisfy the customer early and continuously

- Welcome changing requirements

- Deliver working software frequently

- Business people and developers must work together daily

- Give developers the environment and support they need

- The most efficient communication is face-to-face conversation

- Working software is the primary measure of progress

- Project members should be able to maintain a constant pace indefinitely

- Continuous attention to technical excellence and good design enhances agility

- Simplicity is essential

- The best architectures, requirements, and designs emerge from self-organizing teams.

- At regular intervals, the team reflects on how to become more effective, then tunes and adjusts its behavior accordingly. 

## Using Sprints to Manage Development Projects

Scrum, and a number of other development processes, work in an interative, timeboxed fashion.  A sprint is a block of time used to work on a project.  A sprint will have a defined set of issues (a piece of work) to be done within this time.  Issues may contain the following info:

- The name of the issue
- Issue priority according to project/product owner or stakeholders
- The description of the work to perform
- The assigned developer
- The state of the issue (if its assigned to a sprint or in the backlog)
- The number of points assigned to a sprint

Multiple sprints of equivalent durations are used to work on a project in an interative fashion.  For example a project may have 10 issues created to define what the project should look like when its done.  Two issues can be worked on within the first sprint, three in the second sprint, and five in third sprint.  If an issue is not finished within the assigned sprint then it can be moved to a future sprint.  There are no more sprints when they are no more issues.  If there are no more sprints then a project is "done"!  Compared to the lifespan of a project, a sprint is a short period of time, perhaps two weeks or a month.

The idea is that work takes as long as it takes and we can communicate to stakeholders the cadence for releases so that we can manage expectations.  We look to avoid planning out issues far into the future and instead focus on the near term.

### Using Points

A point system can be used to figure out how many issues can fit in a particular sprint.  It is preferred not to think of points as units of time, an alternative would be measures of complexity.  This will often times be a finger in the air assessment as compared to previous completed work, or if its the very first issue then the points will be quite arbitrary.  The points themselves can be done any number of ways but an easy one is to use the Fibonacci Sequence: 1, 2, 3, 5, 8, 13, 20, etc...  An example:

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

## Project Tooling

To aid in the automation of manual processes, tools can be used to speed things up.

- Project Documentation: Jira, Gitlab, Trello, Confluence, etc...
- Code and Artifact Repositories: Git, Github, Gitlab, Artifactory, Nexus, Subversion, etc...
- CI or Build Servers: Drone, CircleCI, TravisCI, Jenkins, etc...
- Release Management: VMware CodeStream, GoCD, Concourse, UrbanCode, etc...

## Useful Links
- http://agilemanifesto.org/

