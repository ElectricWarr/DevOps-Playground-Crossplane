# Claims

This diagram should make a little more sense now:

<img src="https://docs.crossplane.io/media/composition-how-it-works.svg" alt="Claim Diagram" width="40%"/>

Claims are a simple, namespaced way to interact with Composite Resources (be careful - not the same as "Compositions"!).

Note that "Claim" is NOT an object defined by Crossplane (there is no `kind: Claim` and `kubectl get Claims` will return `error: the server doesn't have a resource type "Claims"`) - instead their type comes from the `claimNames` field in an XRD.

While the structure of a Claim is defined by the relevant XRD, parameters specified on Claims are consumed via a Composition to template resources in a Composite Resource.

## Creating Claims

Creating a claim is a simple as defining any other Kubernetes resource (!).

Let's put together a Claim against an RDS instance by referencing the output of `kubectl explain`:

<details>
  <summary>Explain Output</summary>

  ```text
  [playground@playground 1c-xrds]$ kubectl explain PostgreSQLInstance.spec.parameters
  GROUP:      panda.io
  KIND:       PostgreSQLInstance
  VERSION:    v1alpha1

  FIELD: parameters <Object>

  DESCRIPTION:
      Parameters for configuring this PostgreSQLInstance's Composite Resource(s).

  FIELDS:
    instanceSize  <string> -required-
      Instance size (AKA "Instance Class") for this RDS instance.

    pandaName     <string> -required-
      The panda name given to you on the Playground Labs website.

    storage       <integer> -required-
      The storage size for this PostgreSQLInstance in GB.
  ```

</details>

We need to specify the above in a `parameters` block in the `spec` of our Claim, and we should be good. Copy the following into a new file called `claims.yaml`, and fill in the missing details `metadata.name` and `spec.parameters.pandaName` _in both Claims_:

```yaml
---
apiVersion: panda.io/v1alpha1
kind: PostgreSQLInstance
metadata:
  name:
spec:
  parameters:
    pandaName:
    instanceSize: t3.micro
    storage: 20
---
apiVersion: panda.io/v1alpha1
kind: PrivateBucket
metadata:
  name:
spec:
  paramaters:
    pandaName:
```

As soon as you've deployed your claims with `kubectl apply`, we're good to move on!

## Navigation

Next step: [Troubleshooting](../2b-troubleshooting/README.md) (spoilers!)

Previous step: [Application Developer Role](../README.md)

Top-Level: [DevOps Playground: Crossplane](../../README.md)
