#!/usr/bin/env bash

if [[ "$1" == "destroy" ]]; then
    echo "removing common services ..."
    #kubectl delete ClusterServiceVersion service-binding-operator.v0.8.0 -n openshift-operators
    kubectl delete OperatorGroup operatorgroup -n ibm-common-services
    kubectl delete ClusterRoleBinding ibm-common-service-webhook-ibm-common-services
    kubectl delete subscription ibm-common-service-operator -n ibm-common-services
    kubectl delete namespace ibm-common-services

else 
    echo "creating common services ..."
    CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)
    kubectl apply -f  "${CHARTS_DIR}/ibm-common.yaml"
    sleep 1m
fi
