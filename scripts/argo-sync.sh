#!/bin/bash

argoPass=$(oc get secret/openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d)
argoURL=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}{"\n"}')
argocd login --insecure --grpc-web $argoURL  --username admin --password $argoPass
argocd app sync policies 
argocd app sync clusters
