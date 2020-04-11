#!/bin/bash

# Fill in the IP address of the local image registry service.

REGISTRY_IP=`kubectl get service/registry -o template --template '{{.spec.clusterIP}}'`
export REGISTRY_IP

cat tekton/pipelineresources/image.yaml.in | envsubst > tekton/pipelineresources/image.yaml