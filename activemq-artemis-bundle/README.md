# activemq-artemis-bunlde

## Install OLM
Check out the latest [releases on github](https://github.com/operator-framework/operator-lifecycle-manager/releases) for release-specific install instructions.

## Create a repository
Create a repository that Kubernetes will uses to pull your catalog image. You can create a public one for free on quay.io, see [how to create a repo](https://docs.quay.io/guides/create-repo.html).

## Build a catalog image
Set your repository in CATALOG_IMG and execute the following command:
```
make CATALOG_IMG=quay.io/my-org/activemq-artemis-operator-index:latest catalog-build
```

## Push a catalog image
Set your repository in CATALOG_IMG and execute the following command:
```
make CATALOG_IMG=quay.io/my-org/activemq-artemis-operator-index:latest catalog-push
```

## Create a catalog source
Set your repository in CATALOG_IMG and execute the following command:
```
CATALOG_IMG=quay.io/my-org/activemq-artemis-operator-index:latest
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: activemq-artemis-operator-source
  namespace: operators
spec:
  displayName: ActiveMQ Artemis Operators
  image: ${CATALOG_IMG}
  sourceType: grpc
EOF
```

## Create a subscription
```
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: activemq-artemis-operator-subscription
  namespace: operators
spec:
  channel: upstream
  name: activemq-artemis-operator
  source: activemq-artemis-operator-source
  sourceNamespace: operators
EOF
```

## Create a single ActiveMQ Artemis
```
kubectl apply -f examples/artemis/artemis_single.yaml
```
