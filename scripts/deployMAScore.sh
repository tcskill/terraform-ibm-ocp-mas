#!/usr/bin/env bash

function showWorking {
  # Usage: run any command in the background, capture it's PID
  #
  # somecommand >> /dev/null 2>&1 &
  # showWorking $!
  #
  PID=$1

  sp='/-\|'
  printf ' '
  while s=`ps -p $PID`; do
      printf '\b%.1s' "$sp"
      sp=${sp#?}${sp%???}
      sleep 0.1s
  done
  printf '\b '
}

function logFailureAndExit {
  echo -e "\n ERROR $1"
  if [[ -z $2 ]]; then
    echo -e
  else
    echo -e "See ${2} for more information.\n"
  fi
  exit 1
}

MAS_DIR=$(cd $(dirname $0)/../charts/mas; pwd -P)


MAS_NAMESPACE="$1"
INSTANCE_ID="$2"
DOMAIN="$3"


# Install MAS Core
if [[ "$4" == "destroy" ]]; then
    echo "removing IBM Maximo Application Suite Core..."
   

else 
    echo "Deploying IBM Maximo Application Core..."
    kubectl apply -f ${MAS_DIR}/my_core_v1_suite_cr.yaml -n ${MAS_NAMESPACE} || logFailureAndExit "Unable to deploy IBM Maximo Applicaton Suite"

    # check deployment and report results
    if [ $? == "0" ]; then
      echo "Waiting for core systems to be ready"
      echo -n "Operator ready              "
      while [[ $(kubectl get deployment/ibm-mas-operator --ignore-not-found=true -o jsonpath='{.status.readyReplicas}' -n ${MAS_NAMESPACE}) != "1" ]];do sleep 5s; done &
      showWorking $!
      printf '\b'
      echo -e "[OK]"

      echo -n "Superuser account ready     "
      while [[ $(kubectl get secret/${INSTANCE_ID}-credentials-superuser --ignore-not-found=true -n ${MAS_NAMESPACE} | wc -l) == "0" ]];do sleep 5s; done &
      showWorking $!
      printf '\b'
      echo -e "[OK]"

      echo -n "Admin dashboard ready       "
      while [[ $(kubectl get deployment/${INSTANCE_ID}-admin-dashboard --ignore-not-found=true -o jsonpath='{.status.readyReplicas}' -n ${MAS_NAMESPACE}) != "1" ]];do sleep 5s; done &
      showWorking $!
      printf '\b'
      echo -e "[OK]"

      echo -n "Core API ready              "
      while [[ $(kubectl get deployment/${INSTANCE_ID}-coreapi --ignore-not-found=true -o jsonpath='{.status.readyReplicas}' -n ${MAS_NAMESPACE}) != "3" ]];do sleep 5s; done &
      showWorking $!
      printf '\b'
      echo -e "[OK]"

      echo "Installation Summary"
      echo "Administration Dashboard URL"
      echo "https://admin.${DOMAIN}"

      echo "Super User Credentials"
      echo -n "Username: "
      kubectl get secret ${INSTANCE_ID}-credentials-superuser -o jsonpath='{.data.username}' -n ${MAS_NAMESPACE} | base64 --decode && echo ""
      echo -n "Password: "
      kubectl get secret ${INSTANCE_ID}-credentials-superuser -o jsonpath='{.data.password}' -n ${MAS_NAMESPACE} | base64 --decode && echo ""

      echo -e "\nPlease make a record of the superuser credentials."
      echo ""
      echo "If this is a new installation, you can now complete the initial setup"
      echo "Sign in as the superuser at this URL:"
      echo "https://admin.${DOMAIN}/initialsetup"
      echo ""

      exit 0
    else
      echo -e "Installation Failed"
      echo ""
      exit 1
    fi
fi


