#!/bin/bash

# Global Parameters -- Change these so that they match your environment
export NSX_MANAGER="cph-nsxt-lm.sddc.lab"
export NSX_USER="admin"
export NSX_PASSWORD="VMware1!VMware1!"


# Certificate parameters -- Change these so that they match your environment
export CERTIFICATE_CHAIN="$HOME/certs/certificate.crt"
export PRIVATE_KEY="$HOME/certs/private.key"
export CERTIFICATE_NSX_DISPLAY_NAME="cph-nsxt-lm"

############################################### No Need to make modifications beyond here ############################################################

# API call to import the certificate to NSX Manager
export URI="/api/v1/trust-management/certificates?action=import"
export METHOD="POST"
export CERTIFICATE_CHAIN_PEM=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $CERTIFICATE_CHAIN)
export PRIVATE_KEY_PEM=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $PRIVATE_KEY)

cat >/tmp/body.json <<EOF
{
  "display_name": "${CERTIFICATE_NSX_DISPLAY_NAME}",
  "pem_encoded": "${CERTIFICATE_CHAIN_PEM}",
  "private_key": "${PRIVATE_KEY_PEM}"
}
EOF

export BODY=$(cat /tmp/body.json)
export RESPONSE=$(curl -v -k -X $METHOD "https://$NSX_MANAGER$URI" -u "$NSX_USER" -p "$NSX_PASSWORD" -H "content-type: application/json" -d "$BODY")
export CERT_ID=$(echo $RESPONSE | jq -r '.results[] | {id} | join(" ")')


# API call to fetch NSX Manager node UUIDs (max 3 nodes, non existing nodes will have value "null")
export URI="/api/v1/cluster"
export METHOD="GET"
export RESPONSE=$(curl -v -k -X $METHOD "https://$NSX_MANAGER$URI" -u "$NSX_USER" -p "$NSX_PASSWORD")
export NODE_UUID_01=$(echo $RESPONSE | jq -r '.nodes[0].node_uuid')
export NODE_UUID_02=$(echo $RESPONSE | jq -r '.nodes[1].node_uuid')
export NODE_UUID_03=$(echo $RESPONSE | jq -r '.nodes[2].node_uuid')


# API call to apply certificate on NSX Manager node 01
export URI="/api/v1/trust-management/certificates/$CERT_ID?action=apply_certificate&service_type=API&node_id=$NODE_UUID_01"
export METHOD="POST"
export RESPONSE=$(curl -v -k -X $METHOD "https://$NSX_MANAGER$URI" -u "$NSX_USER" -p "$NSX_PASSWORD" -H "content-type: application/json")


# API call to apply certificate on NSX Manager node 02
export URI="/api/v1/trust-management/certificates/$CERT_ID?action=apply_certificate&service_type=API&node_id=$NODE_UUID_02"
export METHOD="POST"
export RESPONSE=$(curl -v -k -X $METHOD "https://$NSX_MANAGER$URI" -u "$NSX_USER" -p "$NSX_PASSWORD" -H "content-type: application/json")


# API call to apply certificate on NSX Manager node 03
export URI="/api/v1/trust-management/certificates/$CERT_ID?action=apply_certificate&service_type=API&node_id=$NODE_UUID_03"
export METHOD="POST"
export RESPONSE=$(curl -v -k -X $METHOD "https://$NSX_MANAGER$URI" -u "$NSX_USER" -p "$NSX_PASSWORD" -H "content-type: application/json")


# API call to apply certificate on NSX Manager VIP (MGMT_CLUSTER)
export URI="/api/v1/trust-management/certificates/$CERT_ID?action=apply_certificate&service_type=MGMT_CLUSTER"
export METHOD="POST"
export RESPONSE=$(curl -v -k -X $METHOD "https://$NSX_MANAGER$URI" -u "$NSX_USER" -p "$NSX_PASSWORD" -H "content-type: application/json")