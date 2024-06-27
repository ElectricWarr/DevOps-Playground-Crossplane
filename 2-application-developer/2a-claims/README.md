# Claims

[Claim Diagram](https://docs.crossplane.io/media/composition-how-it-works.svg)

"Composite Resources" or "XRs" are created based on Compositions in a similar way to Claims, with the main difference being that they are cluster-scoped (ie do not belong to a specific namespace).

Claims are created based on CRDs defined in XRDs

Claims are used to create a namespace-scoped object which causes resources to be created based on a Composition. Parameters specified on Claims are used to template resources in a Composition.
