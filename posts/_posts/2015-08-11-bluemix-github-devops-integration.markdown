---
layout: post
title: "Building a Bluemix Pipeline with GitHub"
tags: bluemix
description: >
  How to set up a continuous delivery Pipeline connected to GitHub in IBM
  Bluemix. Build stage, test stage, deploy stage... you name it!
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

![create](/assets/images/post-images/bluemix-github-pipeline/01_create.png)

Name your project and click on "link to an existing GitHub repository." By
convention, I prefer to name my IBM Devops project the same name as my Bluemix
project.

![link](/assets/images/post-images/bluemix-github-pipeline/02_link.png)

Select the repo that contains the code for your project.

![select](/assets/images/post-images/bluemix-github-pipeline/03_select.png)

Now it's project configuration time. For the purposes of this demo, we're going
to make it private and without scrum development tools.

**Make sure to select "Make this a Bluemix Project,"** otherwise you won't be
able to push the updates. Select the proper organization and space that houses
your application.

![config](/assets/images/post-images/bluemix-github-pipeline/04_config.png)

You should see a success notification. To get to the build pipeline view for
"Part 2," click the "build & deploy button.

![success](/assets/images/post-images/bluemix-github-pipeline/05_success.png)

For a sanity check, you can verify that the following webhook was added to your
GitHub repo:

![webhook](/assets/images/post-images/bluemix-github-pipeline/06_webhook.png)

##Part 2: Configure your build pipeline.

Full docs [here](https://hub.jazz.net/docs/deploy/).

In this example, we're going to be creating two stages: test/build and deploy.
The test/build stage is going to have three jobs - install dependencies, test,
and build. The deploy stage will only have one job - deploy.

Let's start by creating a stage - click "Add Stage."

![create stage](/assets/images/post-images/bluemix-github-pipeline/07_create_stage.png)

Name this stage "Test + Build." Make sure that "Run jobs whenever a change is
pushed to Git" is selected.

![new stage](/assets/images/post-images/bluemix-github-pipeline/08_new_stage.png)

We're going to add three "build" jobs:

![new jobs](/assets/images/post-images/bluemix-github-pipeline/09_new_jobs.png)

For the purposes of this demo, we're going to use npm for our "Builder Type." We
also have our npm scripts configured such that `test` runs our tests, and
`build` does our build.

![builder type](/assets/images/post-images/bluemix-github-pipeline/10_builder_type.png)

Stage 1, "Install Dependencies" uses as a build script:

    npm install

Stage 2, "Test" uses as a build script:

    npm run test

Stage 3, "Build" uses as a build script:

    npm run build

Now all we need to do is create our deploy stage (by clicking add stage again):

![new deploy](/assets/images/post-images/bluemix-github-pipeline/11_new_deploy.png)

And then create a deploy job in our deploy stage.

![new deploy job](/assets/images/post-images/bluemix-github-pipeline/12_new_deploy_job.png)

For both of these, I've always found the defaults to be sufficient.

##Part 3: Relax.

Now every time you push to your GitHub repo, your pipeline will run.

![voila](/assets/images/post-images/bluemix-github-pipeline/13_voila.png)
