#!/usr/bin/env bash

ICSNAMESP="$1"

if [[ "$2" == "destroy" ]]; then
    echo "removing common services ..."

    kubectl delete OperandRegistry common-service -n ${ICSNAMESP}
    kubectl delete OperandConfig common-service -n ${ICSNAMESP}
    kubectl delete ClusterServiceVersion operand-deployment-lifecycle-manager.v1.11.0 -n ${ICSNAMESP}
    kubectl delete NamespaceScope common-service -n ${ICSNAMESP}
    kubectl delete NamespaceScope nss-managedby-odlm -n ${ICSNAMESP}
    kubectl delete NamespaceScope nss-odlm-scope -n ${ICSNAMESP}
    kubectl delete NamespaceScope odlm-scope-managedby-odlm -n ${ICSNAMESP}
    kubectl delete CommonService common-service -n ${ICSNAMESP}
    kubectl delete ClusterServiceVersion ibm-common-service-operator.v3.13.0 -n ${ICSNAMESP}
    kubectl delete Deployment ibm-common-service-webhook -n ${ICSNAMESP}
    kubectl delete ConfigMap ibm-cpp-config -n ${ICSNAMESP}
    kubectl delete ConfigMap ibm-cs-operator-webhook-ca -n ${ICSNAMESP}
    kubectl delete Service ibm-common-service-webhook -n ${ICSNAMESP}
    kubectl delete namespace ${ICSNAMESP}

else 
    echo "creating common services ..."
    CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)
    
    echo "Installing ibm-mas operator..."
    sed -e "s/{{ICSNAMESPACE}}/${ICSNAMESP}/g" \
        $CHARTS_DIR/ibm-common.yaml > $MAS_DIR/my-ibm-common.yaml
    
    kubectl apply -f  "${CHARTS_DIR}/my-ibm-common.yaml"
    sleep 1m
fi
