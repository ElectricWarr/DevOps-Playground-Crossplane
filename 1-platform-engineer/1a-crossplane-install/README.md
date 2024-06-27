# Crossplane Install

First up, we need to install Crossplane. We're going to use `helm`, which if you're not familiar you can think of as being like a package manager for Kubernetes.

Three simple commands to run in your terminal (if you don't want to write long lines out, you can paste with `Ctrl + Ins`)

1. Add the `crossplane-stable` Helm Repo
2. Update Helm's list of available packages ("Charts")
3. Install Crossplane's latest stable version into the `crossplane-system` namespace, which will be created if it doesn't already exist.

```shell
helm repo add crossplane-stable https://charts.crossplane.io/stable

helm repo update

helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
```

The output should look like this:

```shell
[playground@playground ~]$ helm repo add crossplane-stable https://charts.crossplane.io/stable
"crossplane-stable" has been added to your repositories

[playground@playground ~]$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "crossplane-stable" chart repository
Update Complete. ⎈Happy Helming!⎈

[playground@playground ~]$ helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
NAME: crossplane
LAST DEPLOYED: Tue Jun 25 14:22:46 2024
NAMESPACE: crossplane-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Release: crossplane

Chart Name: crossplane
Chart Description: Crossplane is an open source Kubernetes add-on that enables platform teams to assemble infrastructure from multiple vendors, and expose higher level self-service APIs for application teams to consume.
Chart Version: 1.16.0
Chart Application Version: 1.16.0

Kube Version: v1.29.4-eks-036c24b
```

Run this command to verify that there are Crossplane pods running in their namespace:

```shell
kubectl get pods -n crossplane-system
```

That's it, _Crossplane_ is installed. Thing is, much like Terraform it won't do very much for us without _Providers_, which we'll look at in the next step.

## Navigation

Next step: [Providers](../1b-providers/README.md)

Top-Level: [DevOps Playground: Crossplane](../../README.md)
