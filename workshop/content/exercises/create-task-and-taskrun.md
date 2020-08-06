As mentioned in the previous section, a `Task` is an ordered series of `steps` that perform a specific task 
as part of a CI/CD process. What was not mentioned is what exactly a `Step` is. In Tekton, a `Step` is a container 
that will execute a particular command or an entire script. A `Task` is used to order the execution of `Steps`, which 
all run on a Kubernetes Pod. 

An example `Task` is shown below:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: echo-task
spec:
  steps:
    - name: echo-first
      image: ubuntu
      command:
        - echo
      args:
        - "Executing first"
    - name: echo-second
      image: ubuntu
      command:
        - echo
      args:
        - "Executing second"
```

Under the `spec` property of a `Task`, you will see the `steps` property where container images are specified via the 
`image` property. In the case of the first `Step` named `echo-first`, it will use the `ubuntu` image to execute a 
`command`, which is just an `echo`. Finally, the `args` property can be used to pass an argument to the `echo` command. 

There is also a second `Step` named `echo-second`. The only difference between the two `Steps` are the arguments passed. The 
first `Step` will print `Executing first` via an `echo` command. The second `Step` will print `Executing second` via an `echo` 
command. Since `echo-first` is listed before `echo-second`, `echo-first` will run before `echo-second` as part of a `TaskRun`. 

To see this in action, create the above `Task` by running the command below:

```execute-1
kubectl apply -f /home/eduk8s/tekton/tasks/echo-task.yaml
```

Using the Tekton CLI, you can view the `Task` has been successfully created:

```execute-1
tkn task ls
```

You should see a `Task` named `echo-task` is available in your namespace. To start this `Task`, you will need to create the following 
`TaskRun`:

```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: echo-task-run-
spec:
  taskRef:
    name: echo-task
  podTemplate:
    securityContext:
      runAsUser: 1001
      runAsGroup: 3000
```

The `TaskRun` above passes information to Tekton about what `Task` should be run and how that `Task` should be run. The `taskRef` property 
is how you specify that you want to run the `echo-task` you just created. The other important piece that is part of the `TaskRun` above is 
a `podTemplate`. 

This `podTemplate` helps to define how `Pods` should be created that will host this `TaskRun`. In the `podTemplate` above, a `securityContext` 
is defined that specifies containers running on any `Pod` hosting this `TaskRun` should run as user 1001 in order to prevent the container from 
being run as root.

Go ahead and create a `TaskRun` by running the following command:

```execute-1
kubectl create -f /home/eduk8s/tekton/tasks/echo-taskrun.yaml
```

In the next section, you will further break down the `TaskRun` you just created. Clear your terminal before continuing: 

```execute-1
clear
```

Click on **TaskRun Breakdown** to continue.