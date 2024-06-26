# DevOps-Playground-Crossplane

DevOps Playground for Crossplane, first presented 2024-06-27

## Intro

## Initial Setup

As long as you are registered for the Meetup event you can request your environment at the [DevOps Playground Lab](lab.devopsplayground.org) site.

Then, open these links as tabs in a new browser window:

- Wetty Console: http://<your-panda>.devopsplayground.org/wetty
- VSCode text editor: http://<your-panda>.devopsplayground.org:8000

Wetty will act as your terminal and has access to everything you need for the playground - please be aware that many commands will not work properly in VSCode (a quirk of our current setup).

In Wetty, enter the `workdir` directory and run the following to set up a connection to Kubernetes:

```shell
./eks-config.sh
```

(This only contains afew simple commands if you're curious, but "connecting to kubernetes" and "creating secrets" are not the focus of our attention today!)

## DIY

x

## Agenda

1. [Platform Engineer Role](1-platform-engineer/README)
    - [Crossplane Installation](1-platform-engineer/1a-crossplane-install/README)
    - [Provider Setup](1-platform-engineer/1b-providers/README)
    - [XRDs](1-platform-engineer/1c-xrds/README)
2. [Application Developer Role](2-application-developer/README)
    - [Claiming an S3 Bucket](2-application-developer/2a-s3/README)
    - [Claiming an RDS Database](2-application-developer/2b-rds/README)
    - [Troubleshooting](2-application-developer/2c-troubleshooting/README)
    - [Teardown](2-application-developer/2d-teardown/README)

## Tips

Open this file in VSCode, hit `Ctrl + Shift + V` for "markdown preview", and navigate through the tutorial from there 😁
