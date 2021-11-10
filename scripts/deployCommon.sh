#!/usr/bin/env bash

if [[ "$1" == "destroy" ]]; then
    echo "removing common services ..."
    kubectl delete OperatorGroup operatorgroup -n ibm-common-services
    kubectl delete ClusterRoleBinding ibm-common-service-webhook-ibm-common-services
    kubectl delete subscription ibm-common-service-operator -n ibm-common-services
    kubectl delete ClusterRole commonservices.operator.ibm.com-v3-admin
    kubectl delete ClusterRole commonservices.operator.ibm.com-v3-crdview
    kubectl delete ClusterRole commonservices.operator.ibm.com-v3-edit
    kubectl delete ClusterRole commonservices.operator.ibm.com-v3-view
    kubectl delete ClusterRole ibm-common-service-webhook
    kubectl delete ClusterRoleBinding secretshare-ibm-common-services
    kubectl delete ClusterRoleBinding system:openshift:controller:image-import-controller

    kubectl delete namespace ibm-common-services

else 
    echo "creating common services ..."
    CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)
    kubectl apply -f  "${CHARTS_DIR}/ibm-common.yaml"
    sleep 1m
fi
