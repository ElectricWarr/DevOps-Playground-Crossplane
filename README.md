# DevOps-Playground-Crossplane

DevOps Playground for Crossplane, first presented 2024-06-27

## Intro

## Initial Setup

As long as you are registered for the Meetup event you can request your environment at the [DevOps Playground Lab](lab.devopsplayground.org) site.

Then, open these links as tabs in a new browser window, replacing `YOUR-PANDA` with what you were given by the Lab website:

- Wetty Console: http://YOUR-PANDA.devopsplayground.org/wetty
- VSCode text editor: http://YOUR-PANDA.devopsplayground.org:8000

Wetty will act as your terminal and has access to everything you need for the playground - please be aware that many commands will not work properly in VSCode (a quirk of our current setup).

In Wetty, enter the `workdir` directory and run the following to set up a connection to Kubernetes:

```shell
./eks-config.sh
```

(This only contains afew simple commands if you're curious, but "connecting to kubernetes" and "creating secrets" are not the focus of our attention today!)

## DIY

If you're from the future (or the past?), and not following this Playground with our provided infrastructure, you will need:

- Access to a Kubernetes cluster
- The `kubectl` and `helm` CLI tools
- Access to an AWS account with the ability to create S3 bucket and RDS instances

I strongly recommend using a fresh Kubernetes cluster that you can delete afterwards, since we're going to create custom objects you are unlikely to want later. If you have Docker Desktop installed you can just hit "Enable Kubernetes" in the settings, which works for me!

For just DIY people: any instance of "panda name" can be replaced by any short string of lowercase letters. _If you're using our infrastructure you must use your assigned panda, else certain steps will not work!_

## Agenda

1. [Platform Engineer Role](1-platform-engineer/README.md)
    - [Crossplane Installation](1-platform-engineer/1a-crossplane-install/README.md)
    - [Provider Setup](1-platform-engineer/1b-providers/README.md)
    - [XRDs](1-platform-engineer/1c-xrds/README.md)
2. [Application Developer Role](2-application-developer/README.md)
    - [Claiming an S3 Bucket](2-application-developer/2a-s3/README.md)
    - [Claiming an RDS Database](2-application-developer/2b-rds/README.md)
    - [Troubleshooting](2-application-developer/2c-troubleshooting/README.md)
    - [Teardown](2-application-developer/2d-teardown/README.md)

## Tips

Open this file in VSCode, hit `Ctrl + Shift + V` for "markdown preview", and navigate through the tutorial from there 😁
