#!/usr/bin/env bash

TM_DIR=$(cd $(dirname $0)/../charts/truststoremgr/deploy; pwd -P)
MAS_DIR=$(cd $(dirname $0)/../charts/mas; pwd -P)
TM_VERSION="${TM_VERSION:-1.1.0}"
ICR_CPOPEN="${ICR_CPOPEN:-icr.io/cpopen}"
ICR_CP="${ICR_CP:-cp.icr.io/cp}"
INSTANCE_ID="$1"
DOMAIN="$2"


echo "update truststore crd..."

sed -e "s|{{ICR_CPOPEN}}|${ICR_CPOPEN}|g" \
-e "s|{{VERSION}}|${TM_VERSION}|g" \
${TM_DIR}/operator.yaml > ${TM_DIR}/my_operator.yaml

echo "update core suite crd..."

sed -e "s|{{INSTANCE_ID}}|${INSTANCE_ID}|g" \
    -e "s|{{DOMAIN}}|${DOMAIN}|g" \
    -e "s|{{ICR_CP}}|${ICR_CP}|g" \
    -e "s|{{ICR_CPOPEN}}|${ICR_CPOPEN}|g" \
    ${MAS_DIR}/core_v1_suite.yaml > ${MAS_DIR}/my_core_v1_suite_cr.yaml
