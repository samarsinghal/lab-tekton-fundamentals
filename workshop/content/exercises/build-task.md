Now that you have an understanding of the basics of a `Task` and a `TaskRun`, 
this next section will allow you to create `Tasks` that can be used as part 
of a `Pipeline`. The `Pipeline` you will create will build an application from 
a Dockerfile, push that resulting container image to an image registry, and deploy 
the pushed image to the namespace you are currently using.

The `Tasks` needed for this `Pipeline` will be as follows:
* Building a container image via a Dockerfile and pushing the image to a registry
* Deploying the pushed container image to your Kubernetes cluster

The first `Task` you will create is named `build-docker-image-from-git-source`. To
explain it better, the `Task` YAML definition will be broken into pieces.

To start, each `Task` specifies the `apiVersion` of the `tekton.dev` API group being used, 
the `kind` of resource being created, and the `name` of the resource being created under 
the `metadata` property:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-docker-image-from-git-source
```

What the information above signifies is that you are creating a `Task` of `apiVersion` `tekton.dev/v1beta1`
and giving it the `name` `build-docker-image-from-git-source`. 

Next, under the `spec` property of the `Task`, you will see the `params` associated with the `Task`. These 
are values that can have default values and be overrode to allow different values to be used at run time as 
part of a `TaskRun`:

```yaml
spec:
  params:
    - name: pathToDockerfile
      type: string
      description: The path to the dockerfile to build
      default: /workspace/docker-source/Dockerfile
    - name: pathToContext
      type: string
      description: |
        The build context used by Kaniko
        (https://github.com/GoogleContainerTools/kaniko#kaniko-build-contexts)
      default: /workspace/docker-source
```

This `Task` has two `params` defined:
* `pathToDockerfile`
* `pathToContext`

The param `pathToDockerfile` is, as its description mentions, `The path to the dockerfile to build`. Its `default` 
value specifies that the Dockerfile of the source code being input to the `Task` exists within a folder in the 
container that executes a `step` (i.e. `/workspace/docker-source/Dockerfile`).

The param `pathToContext` specifies the Docker build context that will be used by the tool that your `Pipeline` will 
use to build a Dockerfile, which is called [`kaniko`](https://github.com/GoogleContainerTools/kaniko#kaniko---build-images-in-kubernetes). 
It represents a directory containing a Dockerfile which `kaniko` will use to build your container image. 

The next portion of the `Task` specifies what `PipelineResources` the `Task` requires to execute:

```yaml  
  resources:
    inputs:
      - name: docker-source
        type: git
    outputs:
      - name: builtImage
        type: image
```

Under the `resources` property of the `Task`, an `input` `PipelineResource` of `type: git` is declared, meaning that this 
`Task` expects a git repository to work with. 

The `output` `PipelineResource` of `type: image` specifies the container image registry, image name, and tag associated with 
the image where a built container image will be pushed to. 

The last portion of the `Task` declares the `step` that is used to build and push a container image to an image registry:

```yaml
  steps:
    - name: build-and-push
      image: gcr.io/kaniko-project/executor:v0.17.1
      # specifying DOCKER_CONFIG is required to allow kaniko to detect docker credential
      env:
        - name: "DOCKER_CONFIG"
          value: "/tekton/home/.docker/"
      command:
        - /kaniko/executor
      args:
        - --dockerfile=$(params.pathToDockerfile)
        - --destination=$(resources.outputs.builtImage.url)
        - --context=$(params.pathToContext)
```

The `name` of the `step` is `build-and-push`, and it uses the official `kaniko` project container image, which allows the 
`step` to run the `command` `/kaniko/executor`. It also adds `args` to the `/kaniko/executor` root command. 

The first `arg` is `--dockerfile=$(params.pathToDockerFile)`, which uses a the `--dockerfile` flag from `/kaniko/executor` 
and the param `pathToDockerfile` you learned about earlier in this section. This will help connect the Dockerfile in the git 
repository that will be passed to this `Task` to build a container image.

The `--destination` flag helps connect information about where to push the container image after it is built. Using the 
`output` resource you saw earlier in this section named `builtImage` that holds information about the image registry, name, 
and tag, this allows `/kaniko/executor` to push the image. 

The last `arg` is `--context`, which is a flag that helps specify the Docker build context for `/kaniko/executor`. The value 
passed to it is the param `pathToContext` from earlier in this section.

To summarize, `build-docker-image-from-git-source` will take a git repository input, build the Dockerfile present in the git 
repository using `kaniko`, and then will push the image to an image registry.

Create `build-docker-image-from-git-source` by running the following command:

```execute-1
kubectl apply -f /home/eduk8s/tekton/tasks/kaniko.yaml
```

To verify the `build-docker-image-from-git-source` was created, run the following command:

```execute-1
tkn task ls
```

You should now see two `Tasks` created in your namespace: `build-docker-image-from-git-source` and `echo-task`.

In the next section, you will learn about the second `Task` for the `Pipeline` you will create to deploy the 
container image built from `build-docker-image-from-git-source`.

Clear your terminal before continuing:

```execute-1 
clear
```

Click the **Deploy Task** button to continue.