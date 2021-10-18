#!/usr/bin/env bash


CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$1" == "destroy" ]]; then
    echo "remove cert-manager..."
    kubectl delete -f  "${CHARTS_DIR}/cert-manager.yaml"
   
else 
    echo "adding cert-manager..."
    kubectl apply -f  "${CHARTS_DIR}/cert-manager.yaml"
fi
