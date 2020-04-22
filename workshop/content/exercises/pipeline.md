You are now ready to create a `Pipeline` that will use the `Tasks` and `PipelineResources` 
you created in previous sections. Before creating the `Pipeline`, you will get a chance to 
have the `Pipeline` broken down into sections to understand how it works.

The `Pipeline` starts by defining what the name of the `Pipeline` is. This `Pipeline` is named 
`go-web-server-pipeline`:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: go-web-server-pipeline
```

The next section of the `Pipeline` specifies what `PipelineResources` need to be provided to run 
this `Pipeline`:

```yaml
spec:
  resources:
    - name: source-repo
      type: git
    - name: image
      type: image
```

The first `PipelineResource` required is of `type: git` and is named `source-repo`. This is how you 
will connect the `PipelineResource` named `go-web-server-git` to a `PipelineRun` that will execute 
`go-web-server-pipeline`. 

The second `PipelineResource` required is of `type: image` and is named `image`. This is how you will 
connect the `PipelineResource` named `go-web-server-image` to a `PipelineRun`.

Using `source-repo` and `image`, `go-web-server-pipeline` will have source code to work with and a location 
to push a built container image.

Under the `tasks` property of a `go-web-server-pipeline`, this will be where the `Tasks` created in previous 
sections will be added:

```yaml
  tasks:
    - name: build-go-web-server
      taskRef:
        name: build-docker-image-from-git-source
      params:
        - name: pathToDockerFile
          value: Dockerfile
      resources:
        inputs:
          - name: docker-source
            resource: source-repo
        outputs:
          - name: builtImage
            resource: image
```

The first `Task` on `go-web-server-pipeline` is named `build-go-web-server`, but the actual `Task` used is declared 
under the property `taskRef`. You will see the `build-docker-image-from-git-source` is the `Task` that is actually 
used even though the `Pipeline` itself allows for different `Task` names to be declared.

Under the `resources` and `params` properties, you can see how this `Pipeline` will pass `PipelineResources` and `params` 
to `build-docker-image-from-git-source`. 

The next `Task` on `go-web-server-pipeline` is named `deploy-go-web-server`:
```yaml
    - name: deploy-go-web-server
      taskRef:
        name: deploy-using-kubectl
      resources:
        inputs:
          - name: source
            resource: source-repo
          - name: image
            resource: image
            from:
              - build-go-web-server
      params:
        - name: path
          value: /workspace/source/k8s.yaml
        - name: yamlPathToImage
          value: "spec.template.spec.containers[0].image"
```

The actual `Task` used is once again declared via a `taskRef` and specifies that `deploy-using-kubectl` is the `Task` that will 
be used. Under the `resources` property, you will see how the `source-repo` and `image` `PipelineResources` are passed to 
`deploy-using-kubectl`. 

Something to make note of under the `resources` property as well is a property called `from`. The `from` property declares that 
the `PipelineResources` used by this `Task` will be supplied from another `Task`. 

In this case, the `PipelineResources` will come from the `Task` that runs before it on the `Pipeline` (i.e. `build-go-web-server`). 
The `from` property is one of a few ways to declare that `Tasks` on a `Pipeline` should run in a certain order. 

Since `deploy-go-web-server` depends on `build-go-web-server`, `deploy-go-web-server` will not run until `build-go-web-server` finishes 
successfully.

There are two `params` passed via `go-web-server-pipeline` to the `deploy-using-kubectl` `Task`. The `value` of the `path` param specifies 
where the manifest file will be located via the container `step` volume that contains the declaration of the `Deployment` and `Service` to 
support the application that will be deployed by `go-web-server-pipeline`. The manifest file is named `k8s.yaml` and will be available via 
the file path specified.

The `value` of the `yamlPathToImage` param is a template spec that specifies the location of the image used for the `Deployment` in the manifest 
YAML file. This will be used by the `replace-image` `step` to use the value of the `PipelineResource` `go-web-server-image`.

Create `go-web-server-pipeline`:

```execute-1
kubectl apply -f /home/eduk8s/tekton/pipeline/pipeline.yaml
```

Verify the creation of `go-web-server-pipeline`:

```execute-1
tkn pipeline ls
```

Now that you have created a `Pipeline`, you have all the necessary resources to create a `PipelineRun` that will build an application into 
a container image, push that image to a local image registry, and then deploy the image as a running container to your Kubernetes cluster.

Clear your terminal before continuing:

```execute-1 
clear
```

Click the **Create a PipelineRun** button to continue.