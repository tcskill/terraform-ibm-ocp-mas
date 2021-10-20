#!/usr/bin/env bash

PROJECTNAME="$1"

echo "removing bas...."

cat <<'EOF'>delete-db.yaml
apiVersion: bas.ibm.com/v1
kind: DeleteCluster
metadata:
  name: deletecluster
spec:
  image_pull_secret: bas-images-pull-secret
EOF

kubectl create -f delete-db.yaml

sleep 5m

kubectl delete AnalyticsProxy analyticsproxydeployment
kubectl delete Subscription behavior-analytics-services-operator-migrated
kubectl delete GenerateKey bas-api-key
kubectl delete OperatorGroup  bas-operator-group
kubectl delete deployment postgres-operator
kubectl delete secret database-credentials
kubectl delete secret grafana-credentials
kubectl delete namespace ${PROJECTNAME}


#oc delete FullDeployment fulldeployment-demo
#oc delete AirgappedDeployment airgapped-demo
#oc delete Dashboard dashboard
#oc delete DeleteCluster deletecluster

