#!/usr/bin/env bash


CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$1" == "destroy" ]]; then
    echo "remove catalog..."
    kubectl delete -f  "${CHARTS_DIR}/catalog.yaml"
   
else 
    echo "adding catalog..."
    kubectl apply -f  "${CHARTS_DIR}/catalog.yaml"
fi
