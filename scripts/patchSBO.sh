#!/usr/bin/env bash


installplan=$(kubectl get installplan -n openshift-operators | grep -i service-binding | awk '{print $1}'); echo "installplan: $installplan"

kubectl patch installplan ${installplan} -n openshift-operators --type merge --patch '{"spec":{"approved":true}}'
    #kubectl delete ClusterServiceVersion service-binding-operator.v0.8.0 -n openshift-operators
   