#!/usr/bin/env bash

function logFailureAndExit {
  echo -e "\n ERROR $1"
  if [[ -z $2 ]]; then
    echo -e
  else
    echo -e "See ${2} for more information.\n"
  fi
  exit 1
}

TM_DIR=$(cd $(dirname $0)/../charts/truststoremgr/deploy; pwd -P)
MAS_NAMESPACE="$1"

# Install (or update) IBM Truststore Manager operator
if [[ "$2" == "destroy" ]]; then
    echo "remove ibm-truststore-mgr ..."
    kubectl delete -f ${TM_DIR}/my_operator.yaml -n ${MAS_NAMESPACE}
    kubectl delete -f ${TM_DIR}/service_account.yaml -n ${MAS_NAMESPACE} 
    kubectl delete -f ${TM_DIR}/role_binding.yaml -n ${MAS_NAMESPACE} 
    kubectl delete -f ${TM_DIR}/role.yaml -n ${MAS_NAMESPACE} 
    kubectl delete -f ${TM_DIR}/crds/truststore-mgr.ibm.com_truststores.yaml -n ${MAS_NAMESPACE} 

else 
    echo "Installing ibm-truststore-mgr operator..."
    TM_CRDS=${TM_DIR}/crds/*
    kubectl apply -f ${TM_DIR}/crds/truststore-mgr.ibm.com_truststores.yaml -n ${MAS_NAMESPACE} || logFailureAndExit "Unable to apply CRD truststore-mgr.ibm.com_truststores.yaml"
    kubectl apply -f ${TM_DIR}/role.yaml -n ${MAS_NAMESPACE}  || logFailureAndExit "Unable to apply truststore-mgr role"
    kubectl apply -f ${TM_DIR}/role_binding.yaml -n ${MAS_NAMESPACE} || logFailureAndExit "Unable to apply truststore-mgr role binding"
    kubectl apply -f ${TM_DIR}/service_account.yaml -n ${MAS_NAMESPACE}  || logFailureAndExit "Unable to apply truststore-mgr service account"
    kubectl apply -f ${TM_DIR}/my_operator.yaml -n ${MAS_NAMESPACE} || logFailureAndExit "Unable to apply ibm-truststore-mgr operator"
fi

