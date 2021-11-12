#!/usr/bin/env bash

CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$1" == "destroy" ]]; then
    echo "remove sbo ..."
    CSV=$(kubectl get subscription rh-service-binding-operator -n openshift-operators -o jsonpath="{.status.installedCSV}")
    kubectl delete ClusterServiceVersion ${CSV} -n openshift-operators
    kubectl delete -f ${CHARTS_DIR}/sbo.yaml
    
else 
    echo "create sbo..."
    kubectl apply -f  "${CHARTS_DIR}/sbo.yaml"
    sleep 1m

    echo "patching sbo..."
    installplan=$(kubectl get installplan -n openshift-operators | grep -i service-binding-operator.v0.8.0 | awk '{print $1}'); echo "installplan: $installplan"

    kubectl patch installplan ${installplan} -n openshift-operators --type merge --patch '{"spec":{"approved":true}}'
fi
