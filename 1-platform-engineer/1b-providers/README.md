# Providers

## Installing Providers

Take a look at the manifest file [`provider-aws.yaml`](provider-aws.yaml).

```yaml
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: aws-s3
spec:
  package: xpkg.upbound.io/upbound/provider-aws-s3:v1.7.0
```

This installs the crossplane's Amazon S3 provider, which includes Kubernetes custom objects we can use to manage resources in Amazon S3.

Go ahead and install it by "applying" the manifest:

```shell
kubectl apply -f provider-aws.yaml
```

You should see output like:

```text
[playground@playground crossplane]$ kubectl apply -f provider-aws.yaml
provider.pkg.crossplane.io/aws-s3 created
```

To check which providers are installed, you can run the following:

```shell
kubectl get Providers
```

Notice anything unusual?

<details>
  <summary>Installed Providers</summary>

  ```text
  [playground@playground crossplane]$ kubectl get Providers
  NAME                          INSTALLED   HEALTHY   PACKAGE                                              AGE
  aws-s3                        True        True      xpkg.upbound.io/upbound/provider-aws-s3:v1.7.0       42s
  upbound-provider-family-aws   True        True      xpkg.upbound.io/upbound/provider-family-aws:v1.7.0   42s
  ```

  An extra provider was installed! We'll see more of this in a moment, but the `family-aws` provider is automatically installed along with the S3 provider
</details>

## Additional Providers

We're going to need the RDS provider in addition to S3, so let's add that to the same file.

First add three dashes `---` under the manifest for the S3 provider, to create two separate YAML documents in the same file. Then, duplicate the S3 provider changing the following values:

- Name: `aws-rds`
- Package: `xpkg.upbound.io/upbound/provider-aws-rds:v1.7.0`

Save the file, run `kubectl apply` again, and verify both providers are installed.

```text
[playground@playground crossplane]$ kubectl apply -f provider-aws.yaml
provider.pkg.crossplane.io/aws-s3 unchanged
provider.pkg.crossplane.io/aws-rds created
```

<details>
  <summary>Example</summary>
  The full file should look like this:

  ```yaml
  ---
  # AWS S3 Provider
  apiVersion: pkg.crossplane.io/v1
  kind: Provider
  metadata:
    name: aws-s3
  spec:
    package: xpkg.upbound.io/upbound/provider-aws-s3:v1.7.0
  ---
  # AWS RDS Provider
  apiVersion: pkg.crossplane.io/v1
  kind: Provider
  metadata:
    name: aws-rds
  spec:
    package: xpkg.upbound.io/upbound/provider-aws-rds:v1.7.0
  ```

  `kubectl get providers` should output:

  ```text
  [playground@playground crossplane]$ kubectl get Providers
  NAME                          INSTALLED   HEALTHY   PACKAGE                                              AGE
  aws-rds                       True        True      xpkg.upbound.io/upbound/provider-aws-rds:v1.7.0      21h
  aws-s3                        True        True      xpkg.upbound.io/upbound/provider-aws-s3:v1.7.0       21h
  upbound-provider-family-aws   True        True      xpkg.upbound.io/upbound/provider-family-aws:v1.7.0   23h
  ```

</details>

## Provider Configuration

We need to give both of our providers some credentials to use to access AWS. Luckily, they're already available in a secret called `aws-creds` in the default namespace:

```text
[playground@playground crossplane]$ kubectl get secrets aws-creds
NAME        TYPE     DATA   AGE
aws-creds   Opaque   1      2d1h
```

This is where that extra provider comes in: we can configure credentials on the parent provider `upbound-provider-family-aws`, and these will be inherited by all the AWS providers we have installed.

Create the following manifest file and name it `provider-aws-config.yaml`:

```yaml
---
# AWS Provider Config
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: aws
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: default
      name: aws-creds
      key: creds
```

Note that we've simply called our ProviderConfig `aws`. Deploy this with `kubectl apply`:

```text
[playground@playground crossplane]$ kubectl apply -f provider-aws-config.yaml
providerconfig.aws.upbound.io/aws created
```

## Navigation

Next step: [Composite Resource Definitions](../1c-xrds/README.md)

Previous step: [Crossplane Install](../1a-crossplane-install/README.md)

Top-Level: [DevOps Playground: Crossplane](../../README.md)
