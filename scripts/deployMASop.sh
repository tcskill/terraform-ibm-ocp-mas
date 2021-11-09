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

MAS_DIR=$(cd $(dirname $0)/../charts/mas; pwd -P)

ICR_CPOPEN="${ICR_CPOPEN:-icr.io/cpopen}"
INSTANCE_ID="$1"
VERSION="$2"

# Install MAS operator
if [[ "$3" == "destroy" ]]; then
    echo "remove ibm-mas operator..."
    kubectl delete -f $MAS_DIR/ibm-mas-${VERSION}.yaml

else 
    echo "Installing ibm-mas operator..."
    sed -e "s|icr.io/cpopen|${ICR_CPOPEN}|g" \
        -e "s/{{INSTANCE_ID}}/${INSTANCE_ID}/g" \
        $MAS_DIR/ibm-mas-${VERSION}.yaml 
        #$MAS_DIR/ibm-mas-${VERSION}.yaml | kubectl apply -f - || logFailureAndExit "Unable to apply ibm-mas operator"
fi

# let the deployment finish
#sleep 4m

