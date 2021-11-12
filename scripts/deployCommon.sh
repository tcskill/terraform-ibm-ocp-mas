#!/usr/bin/env bash

if [[ "$1" == "destroy" ]]; then
    echo "removing common services ..."

    kubectl delete OperandRegistry common-service -n ibm-common-services
    kubectl delete OperandConfig common-service -n ibm-common-services
    kubectl delete ClusterServiceVersion operand-deployment-lifecycle-manager.v1.11.0 -n ibm-common-services
    kubectl delete NamespaceScope common-service -n ibm-common-services
    kubectl delete NamespaceScope nss-managedby-odlm -n ibm-common-services
    kubectl delete NamespaceScope nss-odlm-scope -n ibm-common-services
    kubectl delete NamespaceScope odlm-scope-managedby-odlm -n ibm-common-services
    kubectl delete CommonService common-service -n ibm-common-services
    kubectl delete ClusterServiceVersion ibm-common-service-operator.v3.13.0 -n ibm-common-services
    kubectl delete Deployment ibm-common-service-webhook -n ibm-common-services
    kubectl delete ConfigMap ibm-cpp-config -n ibm-common-services
    kubectl delete ConfigMap ibm-cs-operator-webhook-ca -n ibm-common-services
    kubectl delete Service ibm-common-service-webhook -n ibm-common-services
    kubectl delete namespace ibm-common-services

else 
    echo "creating common services ..."
    CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)
    kubectl apply -f  "${CHARTS_DIR}/ibm-common.yaml"
    sleep 1m
fi
