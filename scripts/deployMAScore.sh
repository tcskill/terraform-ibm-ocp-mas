#!/usr/bin/env bash

MAS_DIR=$(cd $(dirname $0)/../charts/mas; pwd -P)
MAS_NAMESPACE="$1"
INSTANCE_ID="$2"
DOMAIN="$3"

# Install MAS Core
if [[ "$4" == "destroy" ]]; then
   echo "removing IBM Maximo Application Suite Core..."
   kubectl delete -f ${MAS_DIR}/my_core_v1_suite_cr.yaml -n ${MAS_NAMESPACE}

else 
    echo "Deploying IBM Maximo Application Core..."
    kubectl apply -f ${MAS_DIR}/my_core_v1_suite_cr.yaml -n ${MAS_NAMESPACE} 

    sleep 20m
    echo "Installation Summary"
    echo "Administration Dashboard URL"
    echo "https://admin.${DOMAIN}"

    echo "Super User Credentials for setup found in ${INSTANCE_ID}-credentials-superuser"

    echo -e "\nPlease make a record of the superuser credentials."
    echo ""
    echo "If this is a new installation, wait for installation to finish"
    echo "Sign in as the superuser at this URL:"
    echo "https://admin.${DOMAIN}/initialsetup"
    echo ""
fi
