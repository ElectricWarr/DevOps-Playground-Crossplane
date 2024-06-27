#! /usr/bin/env bash

for kind in PrivateBucket PostgreSQLInstance Composition CompositeResourceDefinition; do
  for object in $(kubectl get "$kind" --no-headers --output=custom-columns=':metadata.name'); do
    kubectl delete --wait=false "$kind/$object"
  done
done
