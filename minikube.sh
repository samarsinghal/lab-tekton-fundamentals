# Script to set up workshop prerequisites on minikube/make workshop available via nip.io
# Includes --workshop option that will also deploy the workshop/trainingportal

minikube start
minikube addons enable ingress
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.11.1/release.yaml
kubectl apply -k "github.com/eduk8s/eduk8s-operator?ref=master"
kubectl set env deployment/eduk8s-operator -n eduk8s INGRESS_DOMAIN=$(minikube ip).nip.io

if [[ -n "$@" ]] && [[ "$@" == "--workshop" ]];
then
    kubectl apply -k .
fi