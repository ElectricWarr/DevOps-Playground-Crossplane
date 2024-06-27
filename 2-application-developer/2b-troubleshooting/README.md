# Troubleshooting

Were our resources deployed as expected?

We can check the surface-level with a few common Kubernetes commands, but we need some extra info to really get the information required to troubleshoot our resources.

Try the following, replacing NAME with the appropriate name you used in your Claims:

```shell
kubectl get PrivateBucket NAME
kubectl get PostgreSQLInstance NAME
kubectl describe PostgreSQLInstance NAME
```

Pay particular attention to the `Status` fields: these contain up-to-date information on what your Claim and it's associated objects may be doing.

In order to explore the child objects, though, we need to describe those resources specifically. Replace `XRID` in the example below with the id you got from describing your `PostgreSQLInstance`:

```shell
kubectl describe XPostgreSQLInstance NAME-XRID
```

We can go one level further, down to specific resources, which in turn have their own IDs:

```shell
kubectl describe Instance NAME-XRID-RESOURCEID
```

Found the problem?

<details>
  <summary>[answer]</summary>
  We specified the wrong `instanceClass` (via our `instanceSize` parameter)!

  All that's required to correct this is to update our Claim with a correct `instanceSize`, `kubectl apply` the manifest, and after a while Crossplane should pick up the change.

  Looks like all we missed was the `db.` off `db.t3.micro` - apologies for tricking you!
</details>

## Cheating

Now we've gone through that all the hard way, it's time to reveal that is does get easier... if you use the `crossplane` CLI.

Try it out:

```shell
crossplane beta trace PostgreSQLInstance NAME
```

## Navigation

Next step: [Teardown](../2b-teardown/README.md)

Previous step: [Claims](../2a-claims/README.md)

Top-Level: [DevOps Playground: Crossplane](../../README.md)
