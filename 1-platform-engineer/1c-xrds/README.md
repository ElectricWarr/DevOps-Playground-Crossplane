# XRDs and Compositions

## XRDs: Composite Resource Definitions

Why not "CRD"? It's already taken in the Kubernetes-specific context of "Custom Resource Definitions"!

XRDs represent custom Kubernetes API definitions, and result in the creation of CRDs. Crossplane and its providers come with some CRDs of their own, but in order to compose some reusable objects of our own with safe, sane (and consensual) defaults, we need to go a step further.

There isn't a good parallel of these in Terraform - the concept doesn't exist.

### Creating XRDs

Today we're going to create XRDs and Compositions to define some S3 and RDS resources for our developer(s) to consume.

Let's start with RDS - open the file `rds-xrd.yaml` and we'll go through some of the settings:

```yaml
---
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xpostgresqlinstances.panda.io
spec:
  group: panda.io
  names:
    kind: XPostgreSQLInstance
    plural: xpostgresqlinstances
  claimNames:
    kind: PostgreSQLInstance
    plural: postgresqlinstances
  versions: []
```

- `spec.group` sets the name of your new API
- `spec.names` sets the type of Kubernetes resource we're defining, and what the pluralised version should look like
- `spec.claimNames` sets the same for Claims, by convention the same as the above but without the preceding `X`
- `metadata.name` MUST be set to `<spec.names.plural>.<group>`
- `versions` will contain a list of API versions, which we'll look at below

Replace `versions: []` in your `rds-xrd.yaml` with the following. Be careful to ensure `versions` is at the same level of indentation as `claimNames`!

```yaml
versions:
- name: v1alpha1
  served: true
  referenceable: true
  schema:
    openAPIV3Schema:
      type: object
      properties:
        spec:
          type: object
          description: |
            The specification for how this PostgreSQLInstance should be
            deployed.
          properties:
            parameters:
              type: object
              description: |
                Parameters for configuring this PostgreSQLInstance's Composite Resource(s).
              properties:
                pandaName:
                  type: string
                  description: |
                    The panda name given to you on the Playground Labs website.
                instanceSize:
                  type: string
                  description: |
                    Instance size (AKA "Instance Class") for this RDS instance.
                storage:
                  type: integer
                  description: |
                    The storage size for this PostgreSQLInstance in GB.
              required:
              - pandaName
              - instanceSize
              - storage
          required:
            - parameters
```

This section contains definitions for two parameters that our developers will need to provide later, and which we will depend on in our Composition to build out unique resources.

<details>
  <summary>Example</summary>
  The full file `rds-xrd.yaml` should look something like this:

  ```yaml
  ---
  apiVersion: apiextensions.crossplane.io/v1
  kind: CompositeResourceDefinition
  metadata:
    name: xpostgresqlinstances.panda.io
  spec:
    group: panda.io
    names:
      kind: XPostgreSQLInstance
      plural: xpostgresqlinstances
    claimNames:
      kind: PostgreSQLInstance
      plural: postgresqlinstances
    versions:
    - name: v1alpha1
      served: true
      referenceable: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              description: |
                The specification for how this PostgreSQLInstance should be
                deployed.
              properties:
                parameters:
                  type: object
                  description: |
                    Parameters for configuring this PostgreSQLInstance's Composite Resource(s).
                  properties:
                    pandaName:
                      type: string
                      description: |
                        The panda name given to you on the Playground Labs website.
                    instanceSize:
                      type: string
                      description: |
                        Instance size (AKA "Instance Class") for this RDS instance.
                    storage:
                      type: integer
                      description: |
                        The storage size for this PostgreSQLInstance in GB.
                  required:
                  - pandaName
                  - instanceSize
                  - storage
              required:
                - parameters
  ```

  </details>

Deploy the RDS XRD using `kubectl apply -f rds-xrd.yaml`. After a moment we can take a look at the potential structure of a Claim using `kubectl explain`, limiting the output down to just `spec.parameters`:

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

## Compositions

Compositions are templates for resource creation: you can think of these as being like Terraform modules.

### Creating Compositions

Compositions are generally a little more verbose than XRDs, so you can copy-paste this one and we'll step through it. Save the following code in `rcs-composition.yaml`:

<details>
  <summary>RDS Composition</summary>

  ```yaml
  ---
  apiVersion: apiextensions.crossplane.io/v1
  kind: Composition
  metadata:
    name: xpostgresqlinstances.aws.panda.io
  spec:
    writeConnectionSecretsToNamespace: crossplane-system
    compositeTypeRef:
      apiVersion: panda.io/v1alpha1
      kind: XPostgreSQLInstance
    resources:
    - name: rdsinstance
      base:
        apiVersion: rds.aws.upbound.io/v1beta3
        kind: Instance
        spec:
          providerConfigRef:
            name: aws
          forProvider:
            username: adminuser
            engine: postgres
            engineVersion: "12"
            skipFinalSnapshot: true
            publiclyAccessible: false
            autoGeneratePassword: true
            passwordSecretRef:
              namespace: crossplane-system
              key: password
      patches:
      - fromFieldPath: "spec.parameters.instanceSize"
        toFieldPath: "spec.forProvider.instanceClass"
      - fromFieldPath: "metadata.labels['crossplane.io/claim-namespace']"
        toFieldPath: "spec.writeConnectionSecretToRef.namespace"
      - type: CombineFromComposite
        combine:
          variables:
          - fromFieldPath: "spec.parameters.pandaName"
          - fromFieldPath: "metadata.uid"
          strategy: string
          string:
            fmt: "postgres-connection-%s-%s"
        toFieldPath: "spec.writeConnectionSecretToRef.name"
      - type: CombineFromComposite
        combine:
          variables:
          - fromFieldPath: "spec.parameters.pandaName"
          - fromFieldPath: "metadata.uid"
          strategy: string
          string:
            fmt: "postgres-password-%s-%s"
        toFieldPath: "spec.forProvider.passwordSecretRef.name"
      - fromFieldPath: "spec.parameters.pandaName"
        toFieldPath: "spec.forProvider.identifierPrefix"
        transforms:
        - type: string
          string:
            fmt: "%s-"
      - fromFieldPath: "spec.parameters.storage"
        toFieldPath: "spec.forProvider.allocatedStorage"
      connectionDetails:
      - fromFieldPath: "status.atProvider.endpoint"
        name: endpoint
      - fromFieldPath: "status.atProvider.address"
        name: host
      - fromFieldPath: "spec.forProvider.username"
        name: username
      - fromConnectionSecretKey: "attribute.password"
        name: password
  ```

</details>

- Top-level attributes: the `apiVersion` and `kind` here are defined by Crossplane, not the RDS provider and not your XRD!
- `spec.compositeTypeRef`: These are defined by your XRD
- `spec.resources`: a list of resources - providers are defined per-resource by `base.apiVersion` and `base.kind`, so you can mix and match!
- `base`: the basis of a resource, to be modified by `patches`
- `base.forProvider`: essentially the parameters for a particular resource, in this case the details of our RDS instance
- `patches`: allow us to modify properties of the instance of our composition and any child resources at creation time. Fair warning: patches are not immediately applied, they _eventually consistent_!

By default a patch pulls some data from a Composite Resource and maps it to a field of a (child) Resource. Patches are powerful, though - we can do transformations on data and combine fields in various ways, demonstrated in a few places above.

Let's also take a quick look at our composition for S3, provided for you in `s3-composition.yaml`:

<details>
  <summary>S3 Composition</summary>

  ```yaml
  ---
  apiVersion: apiextensions.crossplane.io/v1
  kind: Composition
  metadata:
    name: privatebucket.aws.panda.io
  spec:
    compositeTypeRef:
      apiVersion: panda.io/v1alpha1
      kind: XPrivateBucket
    patchSets:
    - name: common
      patches:
      - fromFieldPath: spec.parameters.region
        toFieldPath: spec.forProvider.region
    resources:
    - name: s3Bucket
      base:
        apiVersion: s3.aws.upbound.io/v1beta1
        kind: Bucket
        spec:
          providerConfigRef:
            name: aws
          forProvider:
            forceDestroy: true
      patches:
      - type: PatchSet
        patchSetName: common
      - fromFieldPath: "metadata.labels['crossplane.io/claim-namespace']"
        toFieldPath: "spec.writeConnectionSecretToRef.namespace"
      - fromFieldPath: "spec.parameters.pandaName"
        toFieldPath: "spec.writeConnectionSecretToRef.name"
        transforms:
        - type: string
          string:
            fmt: "s3-connection-%s"
    - name: s3PublicAccessBlock
      base:
        apiVersion: s3.aws.upbound.io/v1beta1
        kind: BucketPublicAccessBlock
        spec:
          providerConfigRef:
            name: aws
          forProvider:
            bucketSelector:
              matchControllerRef: true
            blockPublicAcls: true
            blockPublicPolicy: true
            ignorePublicAcls: true
            restrictPublicBuckets: true
      patches:
          - type: PatchSet
            patchSetName: common
    - name: s3ServerSideEncryption
      base:
          apiVersion: s3.aws.upbound.io/v1beta1
          kind: BucketServerSideEncryptionConfiguration
          spec:
            providerConfigRef:
              name: aws
            forProvider:
              bucketSelector:
                matchControllerRef: true
              rule:
                - applyServerSideEncryptionByDefault:
                    - sseAlgorithm: AES256
      patches:
          - type: PatchSet
            patchSetName: common
  ```

</details>

Things to note briefly here:

- Multiple resources
- A `patchSet` to apply common patches over multiple resources, keeping things DRY
- A somewhat cheeky patch overrides any region set by users to `eu-west-2` (🤫)

## Publishing XRDs and Compositions

To publish our new custom resources and templates, we just `kubectl apply` them. Strictly speaking the order matters, but if you like you can apply everything at once and run the command multiple times.

```shell
kubectl apply -f rds-xrd.yaml -f s3-xrd.yaml
kubectl apply -f rds-composition.yaml -f s3-composition.yaml
```

If everything has gone well, our developers should be able to use the templates (Compositions) we've just provided to provision their own resources with very little effort.

## Navigation

Next step: [Application Developer Role](../../2-application-developer/README.md)

Previous step: [Providers](../1b-providers/README.md)

Top-Level: [DevOps Playground: Crossplane](../../README.md)
