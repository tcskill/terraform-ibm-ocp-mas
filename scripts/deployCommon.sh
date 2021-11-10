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
    kubectl delete ClusterServiceVersion ibm-common-service-operator.v3.13.0 -n ibm-common-services

    #kubectl delete Deployment ibm-common-service-operator -n ibm-common-services
    kubectl delete Deployment ibm-common-service-webhook -n ibm-common-services
    kubectl delete Deployment ibm-namespace-scope-operator -n ibm-common-services
    kubectl delete Deployment operand-deployment-lifecycle-manager -n ibm-common-services
    #kubectl delete Deployment secretshare -n ibm-common-services
    kubectl delete Service ibm-common-service-webhook -n ibm-common-services
    #kubectl delete ConfigMap ibm-bedrock-version -n ibm-common-services
    kubectl delete ConfigMap ibm-cpp-config -n ibm-common-services
    #kubectl delete ConfigMap ibm-cs-operator-webhook-ca -n ibm-common-services
    kubectl delete ConfigMap namespace-scope -n ibm-common-services
    kubectl delete ConfigMap odlm-scope -n ibm-common-services

    kubectl delete namespace ibm-common-services

else 
    echo "creating common services ..."
    CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)
    kubectl apply -f  "${CHARTS_DIR}/ibm-common.yaml"
    sleep 1m
fi
