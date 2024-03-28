#!/bin/bash
CLUSTERNAME=$1

while true; do
  echo -----$(date)----------
  oc --kubeconfig=${KUBECONFIG} -n ${CLUSTERNAME} get agentclusterinstalls ${CLUSTERNAME} -ojson|jq .status.conditions[0]
  oc --kubeconfig=${KUBECONFIG} -n ${CLUSTERNAME} get agentclusterinstalls ${CLUSTERNAME} -ojson|jq .status.debugInfo.state
  echo  
  oc --kubeconfig=${KUBECONFIG} get managedcluster
  echo  
  oc --kubeconfig=${KUBECONFIG} -n ${CLUSTERNAME} get agent
  echo  
  echo "######## DEBUG ##########"
  oc --kubeconfig=${KUBECONFIG} -n ${CLUSTERNAME} get agentclusterinstalls ${CLUSTERNAME} -ojsonpath='{.status.debugInfo.eventsURL}' | xargs curl -k % 2> /dev/null | jq . | grep "message"
  sleep 15
done

# oc get agentclusterinstalls.extensions.hive.openshift.io
# oc get mch -A

