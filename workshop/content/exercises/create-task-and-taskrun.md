As mentioned in the previous section, a `Task` is an ordered series of steps that perform a specific task 
as part of a CI/CD process. What was not mentioned is what exactly a `Step` is. In Tekton, a `Step` is actually 
a container that will execute a particular command. A `Task` is used to order the execution of `Steps`, which 
all run on a Kubernetes Pod. 

An example `Task` is shown below:

```yaml
apiVersion: tekton.dev/v1alpha1
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
`command`, which is just an `echo`. Finally, the `args` property can be used to pass an argument to the `echo-first` `Step`. 

There is also a second `Step` named `echo-second`. The only difference between the two `Steps` are the arguments passed. The 
first `Step` will print `Executing first` via an `echo` command. The second `Step` will print `Executing second` via an `echo` 
command. Since `echo-first` is listed before `echo-second`, `echo-first` will run before `echo-second` as part of a `TaskRun`. 

To see this in action, create the above `Task` by running the command below:

```execute-1
kubectl apply -f /home/eduk8s/workshop/content/exercises/resources/echo-task.yaml
```

Using the Tekton CLI, you can view the `Task` has been successfully created:

```execute-1
tkn task ls
```

You should see a `Task` named `echo-task` is available in your namespace. Go ahead and run this `Task` by running the following command:

```execute-1
tkn task start echo-task
```

In the next section, you will further break down the `TaskRun` you just created. Clear your terminal before continuing: 

```execute-1
clear
```

Click on **TaskRun Breakdown** to continue.