## Step 1: Get the Execution ID of a Failed Run
From the Workflows UI, open a failed execution and note the execution ID from the URL or the execution detail panel.

## Step 2: Collect Execution Logs
```
GET kbn:/api/workflows/executions/<executionId>/logs
```

## Step 3: Collect Step Details for the Failing Step
From the execution detail view, note the step execution ID of the failing step, then run:
```
GET kbn:/api/workflows/executions/<executionId>/step/<stepExecutionId>
```

## Step 4: Check Workflow Engine Configuration
```
GET kbn:/internal/workflows/config
```
