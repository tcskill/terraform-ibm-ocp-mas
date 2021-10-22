#!/usr/bin/env bash

PROJECTNAME="$1"
storageClassArchive="$2" 
storageClassDB="$3" 
storageClassKafka="$4" 
storageClassZookeeper="$5" 
dbuser="$6"
dbpassword="$7"
grafanauser="$8"
grafanapassword="$9"


CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

####Keeping the values of below properties to default is advised.
storageSizeKafka=20G
storageSizeZookeeper=20G
storageSizeDB=20G
storageSizeArchive=20G
eventSchedulerFrequency="'*/10 * * * *'"
#prometheusSchedulerFrequency='@daily'
envType=lite
ibmproxyurl='https://iaps.ibm.com'
airgappedEnabled=false
imagePullSecret=bas-images-pull-secret
requiredVersion="^.*4\.([0-9]{3,}|[3-9]?)?(\.[0-9]+.*)*$"
requiredServerVersion="^.*1\.([0-9]{16,}|[3-9]?)?(\.[0-9]+)*$"
ocpVersion="^\"4\.([0-9]{6,}|[6-9]?)?(\.[0-9]+.*)*$"
ocpVersion45="^\"4\.5\.[0-9]+.*$"
basVersion=v1.0.0

function getGenerateAPIKey() {

	retryCount=10
	retries=0
	check_for_key=$(kubectl get secret bas-api-key --ignore-not-found)
	until [[ $retries -eq $retryCount || $check_for_key != "" ]]; do
		sleep 5
		check_for_key=$(kubectl get secret bas-api-key --ignore-not-found)
		retries=$((retries + 1))
	done
	if [[ $check_for_key != "" ]]; then
	   check_for_key=$(kubectl get secret bas-api-key --output="jsonpath={.data.apikey}" | base64 -d)
	fi
	echo "$check_for_key"
}

#create BAS namespace project
kubectl create namespace ${PROJECTNAME}
sleep 10s

#create operator group
cat > "${CHARTS_DIR}/bas-og.yaml" << EOL
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: bas-operator-group
  namespace: ${PROJECTNAME} 
spec: 
  targetNamespaces:
  - ${PROJECTNAME}
EOL

kubectl create -f ${CHARTS_DIR}/bas-og.yaml 

#create a Subscription object
cat > "${CHARTS_DIR}/bas-subscription.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: behavior-analytics-services-operator-certified
  namespace: ${PROJECTNAME}
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: behavior-analytics-services-operator-certified
  source: certified-operators
  sourceNamespace: openshift-marketplace
  startingCSV: behavior-analytics-services-operator.${basVersion}
EOL

kubectl create -f ${CHARTS_DIR}/bas-subscription.yaml

#Create a secret named database-credentials for PostgreSQL DB and grafana-credentials for Grafana
kubectl create secret generic database-credentials --from-literal=db_username=${dbuser} --from-literal=db_password=${dbpassword} -n ${PROJECTNAME} 
kubectl create secret generic grafana-credentials --from-literal=grafana_username=${grafanauser} --from-literal=grafana_password=${grafanapassword} -n ${PROJECTNAME}

#Create the AnalyticsProxy instance
cat > "${CHARTS_DIR}/analytics-proxy.yaml" << EOL
apiVersion: bas.ibm.com/v1
kind: AnalyticsProxy
metadata:
  name: analyticsproxydeployment
spec:
  allowed_domains: "*"
  db_archive:
    frequency: '@monthly'
    retention_age: 6
    persistent_storage:
      storage_class: ${storageClassArchive}
      storage_size: ${storageSizeArchive}
  airgapped:
    enabled: ${airgappedEnabled}
    backup_deletion_frequency: '@daily'
    backup_retention_period: 7
  event_scheduler_frequency: ${eventSchedulerFrequency}
  ibmproxyurl: ${ibmproxyurl}
  image_pull_secret: ${imagePullSecret}
  postgres:
    storage_class: ${storageClassDB}
    storage_size: ${storageSizeDB}
  kafka:
    storage_class: ${storageClassKafka}
    storage_size: ${storageSizeKafka}
    zookeeper_storage_class: ${storageClassZookeeper}
    zookeeper_storage_size: ${storageSizeZookeeper}
  env_type: ${envType}
EOL

kubectl create -f ${CHARTS_DIR}/analytics-proxy.yaml
#Sleep for 50 mins for the deployment
sleep 50m

#Generate an API Key to use it for authentication
cat > "${CHARTS_DIR}/api-key.yaml" << EOL
apiVersion: bas.ibm.com/v1
kind: GenerateKey
metadata:
  name: bas-api-key
spec:
  image_pull_secret: bas-images-pull-secret
EOL

kubectl create -f ${CHARTS_DIR}/api-key.yaml


check_for_key=$(getGenerateAPIKey)

#Get the URLS
bas_endpoint_url=https://$(kubectl get routes bas-endpoint -n ${PROJECTNAME} |awk 'NR==2 {print $2}')
grafana_dashboard_url=https://$(kubectl get routes grafana-route -n ${PROJECTNAME} |awk 'NR==2 {print $2}')

#Get the API key value and the URLs
echo "===========API KEY=============="
echo $check_for_key
echo "===========BAS Endpoint URL=============="
echo $bas_endpoint_url
echo "===========Grafana URL=============="
echo $grafana_dashboard_url

