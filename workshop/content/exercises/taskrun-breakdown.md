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
name to help identify a particular run for a `Task`. Additionally, `tkn tr ls`, 
which uses the `tkn tr` shorthand for `tkn taskrun`, shows information about the 
start time (`STARTED`), how long the `TaskRun` took to execute (`DURATION`), and 
shows the success or failure of the `TaskRun` (`STATUS`).

Your `TaskRun` has a `STATUS` of succeeded, indicating the `Task` executed successfully. 
You can further verify this by taking a look at the logs of the last `TaskRun` to verify 
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
and save it to a variable named `TASKRUN1`:

```execute-1
RUN=`tkn tr ls -o name --limit 1`; TASKRUN1=$(echo "${RUN:19}")
```

Run the following to describe the `TaskRun`:

```execute-1
tkn tr desc $TASKRUN1
```