You have now successfully used a `Pipeline` to deploy a container-hosted application
to your Kubernetes cluster. To verify it was deployed successfully, run the following 
command to grab the `ClusterIP` of the `Service` created for your `Deployment`:

{% raw %}
```execute-1
DEPLOYMENT_IP=`kubectl get svc/go-web-server-service -o template --template '{{.spec.clusterIP}}'`
```
{% endraw %}

Run the following command to ping the application to get back a response:

```execute-1
curl $DEPLOYMENT_IP:8080/Tekton
```

You should get back a response of `Hi there, I love Tekton!`, which confirms a successful deployment.