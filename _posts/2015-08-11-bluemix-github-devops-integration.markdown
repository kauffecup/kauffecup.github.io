---
layout: post
title:  "Building a Bluemix Pipeline with GitHub"
date:   2015-08-11 10:15:38 -0500
categories: bluemix
---

Continuous delivery is awesome. Nothing beats the ease of delivering code and
having your entire pipeline kick off, updating your application, without you
having to do anything.

Bluemix makes this easy to do.

Configuring a pipeline with Bluemix and GitHub is split in two parts - creating
an IBM Devops project, and configuring your pipeline. Creating the Devops
project is as simple as clicking a few buttons and linking your Bluemix project
to a GitHub repo. Configuring your pipeline is as simple as adding a few stages
and jobs that feed in to each other.

There are a lot of screenshots in this post, but fear not - they're here to make
things easier to explain, not because this is a difficult process.

Prerequisites:

  1. A [Bluemix](https://bluemix.net/) account
  1. An [IBM Devops](https://hub.jazz.net/register) account
  1. A [Github](https://github.com/) account
  1. Create a Bluemix Project
  1. Push that project's code to a Github Repo

##Part 1: Configure your Devops project.

Navigate on over to [IBM Devops](https://hub.jazz.net/), and click "Create
Project"

![create](http://i.imgur.com/zC1yUXo.png)

Name your project and click on "link to an existing GitHub repository." By
convention, I prefer to name my IBM Devops project the same name as my Bluemix
project.

![link](http://i.imgur.com/YKawNQH.png)

Select the repo that contains the code for your project.

![select](http://i.imgur.com/sO78u6W.png)

Now it's project configuration time. For the purposes of this demo, we're going
to make it private and without scrum development tools.

**Make sure to select "Make this a Bluemix Project,"** otherwise you won't be
**able to push the updates. Select the proper organization and space that houses
**your application.

![config](http://i.imgur.com/on8UF7Y.png)

You should see a success notification. To get to the build pipeline view for
"Part 2," click the "build & deploy button.

![success](http://i.imgur.com/Eh6jwI6.png)

For a sanity check, you can verify that the following webhook was added to your
GitHub repo:

![webhook](http://i.imgur.com/3uV0w85.png)

##Part 2: Configure your build pipeline.

Full docs [here](https://hub.jazz.net/docs/deploy/).

In this example, we're going to be creating two stages: test/build and deploy.
The test/build stage is going to have three jobs - install dependencies, test,
and build. The deploy stage will only have one job - deploy.

Let's start by creating a stage - click "Add Stage."

![create stage](http://i.imgur.com/9g8W2T9.png)

Name this stage "Test + Build." Make sure that "Run jobs whenever a change is
pushed to Git" is selected.

![new stage](http://i.imgur.com/nF9ScYM.png)

We're going to add three "build" jobs:

![new jobs](http://i.imgur.com/TpZFaZt.png)

For the purposes of this demo, we're going to use npm for our "Builder Type." We
also have our npm scripts configured such that `test` runs our tests, and
`build` does our build.

![builder type](http://i.imgur.com/ochjTuA.png)

Stage 1, "Install Dependencies" uses as a build script:

    npm install

Stage 2, "Test" uses as a build script:

    npm run test

Stage 3, "Build" uses as a build script:

    npm run build

Now all we need to do is create our deploy stage (by clicking add stage again):

![new deploy](http://i.imgur.com/QL7rtuB.png)

And then create a deploy job in our deploy stage.

![new deploy job](http://i.imgur.com/klUXbHp.png)

For both of these, I've always found the defaults to be sufficient.

##Part 3: Relax.

Now every time you push to your GitHub repo, your pipeline will run.

![voila](http://i.imgur.com/znHuxvy.png)
