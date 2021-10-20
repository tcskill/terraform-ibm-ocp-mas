#!/usr/bin/env bash

PROJECTNAME="$1"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

echo "removing bas...."

cat > "${CHARTS_DIR}/delete-db.yaml" << EOL
apiVersion: bas.ibm.com/v1
kind: DeleteCluster
metadata:
  name: deletecluster
spec:
  image_pull_secret: bas-images-pull-secret
EOL

kubectl create -f ${CHARTS_DIR}/delete-db.yaml

sleep 5m

kubectl delete AnalyticsProxy analyticsproxydeployment
kubectl delete Subscription behavior-analytics-services-operator-migrated
kubectl delete GenerateKey bas-api-key
kubectl delete OperatorGroup bas-operator-group
kubectl delete Deployment postgres-operator
kubectl delete Deployment behavior-analytics-services-operator
kubectl delete Deployment dashboard-deployment
kubectl delete secret database-credentials
kubectl delete secret grafana-credentials
kubectl delete namespace ${PROJECTNAME}


#oc delete FullDeployment fulldeployment-demo
#oc delete AirgappedDeployment airgapped-demo
#oc delete Dashboard dashboard
#oc delete DeleteCluster deletecluster

