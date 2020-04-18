As a refresher of what you have learned, a `PipelineRun` is how run time information can be 
passed to a `Pipeline` and its associated `Tasks`. For the `Pipeline` you have created, there 
are three run time values to specify for a `PipelineRun`:
* A `PipelineResource` for a git repository
* A `PipelineResource` representing where to push a container image
* A `ServiceAccount` with appropriate permission to create a `Deployment` and `Service`

To pass all of this information to a `PipelineRun`, you can use `tkn pipeline start` to create 
a `PipelineRun` that will run your `Pipeline`. Before actually starting a `PipelineRun`, you can 
use the `tkn` `--dry-run` option to preview the `PipelineRun`:

```execute-1
tkn pipeline start go-web-server-pipeline -r source-repo=go-web-server-git -r image=go-web-server-image -s tekton-sa --dry-run
```

You should see the following output from the command:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  creationTimestamp: null
  generateName: go-web-server-pipeline-run-
  namespace: lab-tekton-fundamentals-w01-s001
spec:
  pipelineRef:
    name: go-web-server-pipeline
  resources:
  - name: source-repo
    resourceRef:
      name: go-web-server-git
  - name: image
    resourceRef:
      name: go-web-server-image
  serviceAccountName: tekton-sa
  timeout: 1h0m0s
status: {}
```

This `PipelineRun` object holds information that will be passed to the Tekton controller running on your cluster, which 
manages Tekton resources on your cluster and the running of `Tasks` and `Pipelines`. 

The object above specifies a `pipelineRef` property to declare what `Pipeline` will be run, a `resources` property to specify 
what `PipelineResources` to pass to the `Pipeline`, and a `serviceAccountName` property to connect your `ServiceAccount` to the 
`PipelineRun`.

If you remove the `--dry-run` option from the `tkn pipeline start` command, you will actually kick off the `PipelineRun`. Notice via 
the `-r` options how your `PipelineResources` are specified for the `PipelineRun` and then how the `-s` option provides a `ServiceAccount`
name argument.

Create the `PipelineRun`:

```execute-1
tkn pipeline start go-web-server-pipeline -r source-repo=go-web-server-git -r image=go-web-server-image -s tekton-sa
```

After running the command above, you will see a confirmation message stating the the `PipelineRun` has been created and is now in progress. 
You can confirm the `PipelineRun` is executing by running the following command:

```execute-1
tkn pipelinerun ls
```

You will see one `PipelineRun` with a unique name with a `STATUS` of `Running`. Since a `PipelineRun` consists of several `TaskRuns`, the creation 
of the above `PipelineRun` should also result in a new `TaskRun` being started.

Run the following command to see the new `TaskRun` that has been created:

```execute-1
tkn taskrun ls
```

You should see a new `TaskRun` with a name containing `build-go-web-server`, which means this `TaskRun` corresponds to the execution of the 
first `Task` on your `Pipeline`.

In the lower terminal, start the logs of the `PipelineRun`:

```execute-2
tkn pr logs --last -f
```

You should begin seeing information about what is occurring during your `PipelineRun` from the logs of the `Pod` hosting the `TaskRun` that is 
executing. The format of the logs of a `PipelineRun` is as follows:

```
[TaskName : StepName]
```

The log output currently being shown is coming from `[build-go-web-server : build-and-push]`, meaning the `build-and-push` `step` is being executed 
in a container via a `/kaniko/executor` command. 

You can also watch the `Pods` that are being created throughout this `PipelineRun` in the first terminal:

```execute-1
watch kubectl get pods
```

You should see a `Pod` currently hosting the `build-go-web-server` `TaskRun`. `Pods` hosting `TaskRuns` will have the name of the `Task` being executed 
in the name of the `Pod`.

The log output from `[build-go-web-server : build-and-push]` will show instructions being executed for building a Dockerfile for a go application.

As soon as the `build-go-web-server` `TaskRun` finishes, a new `Pod` will be created to host the second `TaskRun` your `Pipeline` will use to deploy an application to your cluster. This `Pod` will have a name containing `deploy-go-web-server`. Keep an eye on the first terminal for this new `Pod` to be 
created before continuing.

Your `PipelineRun` is finished executing when you see the following output from the logs, which means the `Deployment` and `Service` for the 
go application being deployed were successfully created:

```
[deploy-go-web-server : run-kubectl] deployment.apps/go-web-server-deployment created
[deploy-go-web-server : run-kubectl] service/go-web-server-service created
```

Wait until you see the above output before continuing. 

After you see the above output, you will notice in your top terminal how two more `Pods` are created with names containing `go-web-server-deployment`. These `Pods` will each host the container built by your `Pipeline`. Wait until both `Pods` have a `STATUS` of `Running` before continuing:

Stop the watch on the `Pods` in the first terminal by running:

```execute-1
<ctrl+c>
```

Clear your terminals before continuing:

```execute-1 
clear
```

```execute-2
clear
```

In the next section, you can view the application your `Pipeline` deployed.

Click the **Verify Deployment** button to continue.