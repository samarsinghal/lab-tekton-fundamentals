In the previous section, you created a `TaskRun`. Go ahead and take a look at 
the status of that `TaskRun`:

```execute-1
tkn tr ls
```

You will see something similar to the following:

```
NAME                  STARTED          DURATION    STATUS
echo-task-run-5jjk4   1 minute ago     9 seconds   Succeeded
```

The `NAME` column shows the name of the `TaskRun`. Each `TaskRun` has a unique 
name to help identify a particular execution of a `Task`. Additionally, `tkn tr ls`, 
which uses the `tkn tr` shorthand for `tkn taskrun`, shows information about the 
start time (`STARTED`), how long the `TaskRun` took to execute (`DURATION`), and 
shows the success or failure of the `TaskRun` (`STATUS`).

Your `TaskRun` has a `STATUS` of `Succeeded`, indicating the `Task` executed successfully. 
You can further verify this by taking a look at the logs of the last `TaskRun` to see if 
`echo-task` carried out the expected `Steps` in the correct order:

```execute-2
tkn tr logs --last
```

The log output you see should be similar to the following:

```
[echo-first] Executing first

[echo-second] Executing second
```

The logs for a particular `Step` are denoted by brackets around the name of the `Step` with the 
output of the `Step` to the right of `Step` name. The output shows the `echo-first` `Step` completed 
followed by the `echo-second` `Step`. 

You can further describe the `TaskRun` using `tkn tr describe`. First, grab the name of the `TaskRun` 
and save it to a variable named `TASKRUN`:

```execute-1
TASKRUN=`tkn tr ls -o jsonpath="{range .items[*]}{.metadata.name}{\"\\n\"}{end}" --limit 1`
```

Run the following to describe the `TaskRun`:

```execute-1
tkn tr desc $TASKRUN
```

`tkn tr desc` shows much more detail about `TaskRuns` that you have created. It is particularly helpful 
for debugging why a `TaskRun` has failed. You should see general information about the `TaskRun`, including 
the `Name` of it, the `Namespace` where the `TaskRun` ran, the `Task Ref` that shows what `Task` was run, 
`Status` information similar to what is available with `tkn tr ls`, and lots of other details that will be more 
relevant in later sections of the workshop. 

One thing to note before moving on is the ability to see the `STATUS` of `Steps` of a `TaskRun`. You should see 
that both the `Steps` of the `TaskRun` are in a `Completed` state, indicating a successful termination state for 
the container.

In the next section, you will learn about and create more advanced `Tasks` as part of building a `Pipeline`. Clear 
your terminals before continuing:

```execute-1 
clear
```

```execute-2
clear
```

Click on **Build Task** to continue.