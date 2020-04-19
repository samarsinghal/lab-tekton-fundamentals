Now that you have created a `Task` to build and push a container image to an image
registry, the next `Task` your `Pipeline` will need is a `Task` that can deploy the 
the container and start it up on Kubernetes.

The `Task` you will create is named `deploy-using-kubectl` as you'll see in the beginning 
of the definition under the `metadata` property:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-using-kubectl
```

Just like with the `build-docker-image-from-git-source` `Task`, this `Task` will feature 
`params`:

```yaml
spec:
  params:
    - name: path
      type: string
      description: Path to the manifest to apply
    - name: yamlPathToImage
      type: string
      description: |
        The path to the image to replace in the yaml manifest (arg to yq)
```

The first param is named `path`, and it is required to run `deploy-using-kubectl` since no `default` value 
is declared for the param. This means a value must be specified for `path` at run time as part of a `TaskRun`. 

The `path` param allows you to specify the location of a Kubernetes manifest to apply via a file path. A manifest 
is a file, which is typically in a YAML format, with a collection of Kubernetes resources. In this sceanrio, the manifest 
will have resources declared to support a container image that you deploy to Kubernetes. 

The second param is named `yamlPathToImage`. Within the manifest this `Task` uses is a property called `containers`, which 
is a list of container images that are part of what is called a Kubernetes `Deployment`. What `yamlPathToImage` allows you 
to specify is what container image should be used in the manifest. This makes sure that the correct container image is deployed 
to Kubernetes via the `Pipeline` you will create.

Once again, this `Task` has `PipelineResources` that it requires in order to be ran:

```yaml
  resources:
    inputs:
      - name: source
        type: git
      - name: image
        type: image
```

This `Task` requires a `PipelineResource` of `type: git` and another of `type: image`, but this isn't quite exactly 
the same as `build-docker-image-from-git-source`. The major difference is that the `image` `PipelineResource` is an 
`input` `PipelineResource` this time instead of an `output` like with `build-docker-image-from-git-source`.

The significance of this is that `deploy-using-kubectl` is expecting a container image as a value that it will use 
instead of something that is produced as a result of the `Task`.

The last portion of this `Task` is a list of its `steps`:

```yaml
  steps:
    # replace-image replaces image specified in manifest
    # with the image resource used for the TaskRun
    - name: replace-image
      image: mikefarah/yq
      command: ["yq"]
      args:
        - "w"
        - "-i"
        - "$(params.path)"
        - "$(params.yamlPathToImage)"
        - "$(resources.inputs.image.url)"
    # run-kubectl applies the manifest passed in via the 
    # path param to deploy the image specified via the image
    # resource
    - name: run-kubectl
      image: lachlanevenson/k8s-kubectl
      command: ["kubectl"]
      args:
        - "apply"
        - "-f"
        - "$(params.path)"
```

The first `step` for `deploy-using-kubectl` is named `replace-image`. This `step` uses the official image for `yq`, which 
is a CLI tool for working with YAML files. For those fimilar with the JSON-equivalent `jq`, it is very similar but focuses 
on creating, editing, and validating YAML files instead of JSON.

`replace-image` uses the root command for the CLI, `yq`, and passes a list of `args` with subcommands and flags to use with 
`yq`. Using `yq w -i`, the goal is to write (`w`) to a YAML file inplace (`-i`) and pass in three arguments that represent 
the following:
* A path to the YAML file to be edited - This `Task` uses `"$(params.path)"` to set specify the location of the YAML manifest file.
* The location of the image property in the manifest - Using a template syntax, the location of the container image in the manifest 
can be specified.
* The image registry, name, and tag - Using the `image` `PipelineResource` via `"$(resources.inputs.image.url)"`, the final arg is 
used to replace what is specified via `"$(params.path)"`.

In summary, `replace-image` makes sure the manifest YAML file you will use to deploy the container built from `build-docker-image-from-git-source` 
is used instead of a hard coded value in the manifest. This allows you to change information at run time via a `TaskRun`.

The second `step` is named `run-kubectl`. This `step` allows you to use `kubectl` during the execution of this `Task` to run an 
`apply -f` subcommand on a file. In this case, using `"$(params.path)"`, `kubectl apply -f` will be used to create the Kubernetes 
resources on your cluster.

You may be wondering where this manifest is located. It will be available in the git repository provided by the `git` `PipelineResource` 
named `source`. So the git repository provided via a `PipelineResource` will be how `run-kubectl` can find the manifest to apply.

Create `deploy-using-kubectl` by running the following command:

```execute-1
kubectl apply -f /home/eduk8s/tekton/tasks/kubectl.yaml
```

Verify the `Task` was created by running the following command:

```execute-1
tkn task ls
```

You should now see a third `Task` in your namespace. You have created all the `Tasks` needed for the `Pipeline` you will create. Before creating 
the `Pipeline`, you should learn a bit about how a Kubernetes `ServiceAccount` can help with automating processes with CI/CD and manage sensitive 
information used during your CI/CD process via Kubernetes `Secrets`.

Clear your terminals before continuing:

```execute-1 
clear
```

Click the **ServiceAccounts** button to continue.