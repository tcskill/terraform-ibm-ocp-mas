#!/usr/bin/env bash

if [[ "$1" == "destroy" ]]; then
    echo "remove sbo ..."
    kubectl delete ClusterServiceVersion service-binding-operator.v0.8.0 -n openshift-operators
else 
    echo "create sbo..."
    CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)
    kubectl apply -f  "${CHARTS_DIR}/sbo.yaml"
    sleep 1m

    echo "patching sbo..."
    installplan=$(kubectl get installplan -n openshift-operators | grep -i service-binding | awk '{print $1}'); echo "installplan: $installplan"

    kubectl patch installplan ${installplan} -n openshift-operators --type merge --patch '{"spec":{"approved":true}}'
fi
