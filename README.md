LAB - Tekton Fundamentals
=========================

This workshop is a work in progress, but aims to explain the fundamentals of using [Tekton](https://github.com/tektoncd/pipeline) for CI/CD with Kubernetes.

Prerequisites
-------------

In order to use the workshop you should have the eduk8s operator installed.

For installation instructions for the eduk8s operator see:

* https://github.com/eduk8s/eduk8s-operator

Tekton must also be installed on your cluster hosting the workshop. You can install it using the following command:

```
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.11.1/release.yaml
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
