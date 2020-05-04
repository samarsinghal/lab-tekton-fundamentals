LAB - Tekton Fundamentals
=========================

This workshop helps teach the fundamentals of using [Tekton](https://github.com/tektoncd/pipeline) for CI/CD with Kubernetes. 
As of this time, it will only run on a Kubernetes cluster provisioned by [Tanzu Mission Control (TMC)](https://tanzu.vmware.com/mission-control?gclid=CjwKCAjw-YT1BRAFEiwAd2WRtqC0WthDAKNAPUQzJF0lMXKelEd1gUJhj4UM9wkHHBK-GXlPeIt99hoCZZIQAvD_BwE). The minimum Kubernetes version is v1.15.0 since Tekton itself requires this version.

Prerequisites
-------------

A Kubernetes cluster v1.15.0 provisioned by Tanzu Mission Control.

In order to use the workshop you should have the eduk8s operator installed. For installation instructions for the eduk8s operator see:

* https://github.com/eduk8s/eduk8s-operator

Tekton must also be installed on your cluster hosting the workshop. Since TMC clusters have a PodSecurityPolicy that prevents images to run as root, but Tekton release runs the webhook image as root, we need to create a rolebinding first.. You can install it using the following command:

```
kubectl create ns tekton-pipelines
kubectl create rolebinding privileged-role-binding-tekton-pipelines-webhook \
               --clusterrole=vmware-system-tmc-psp-privileged \
               --serviceaccount=tekton-pipelines:tekton-pipelines-webhook \
               -n tekton-pipelines
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.12.0/release.yaml
```

Deployment
----------

To deploy the workshop environment run:

```
kubectl apply -k github.com/danielhelfand/lab_tekton_fundamentals
```

Then run:

```
kubectl get trainingportal/lab-tekton-fundamentals
```

This will output the URL to access the web portal for the training environment.

You need to be a cluster admin to create the deployment using this method.

Deletion
--------

When you are finished with the workshop environment, you can delete it by running:

```
kubectl delete -k github.com/danielhelfand/lab_tekton_fundamentals
```
