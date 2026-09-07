Deploying the payments service
==============================

[TOC]

This page explains how to deploy the payments service to staging and prod. Read it before your first deploy, and see the runbook if something is on fire during one.

## Prerequisites
You need prod access, the `paycli` binary, and membership in the payments-oncall group. Ask in the team channel if you are missing any of these, someone will sort you out.

<br>

## Before you deploy

Run the smoke suite first:

    paycli smoke --env=staging

Then check the dashboard [here](https://dashboards.example.com/payments) and make sure error rate is flat.  

If it is not flat, stop and read [https://example.com/docs/payments/incident.md](https://example.com/docs/payments/incident.md).

## Staging

### Summary
Deploy to staging happens on every merge to main, and you usually do not need to do anything at all unless the pipeline is red.

### Example

```
paycli deploy --env=staging --service=payments
  --wait --timeout=15m
```

* Watch the rollout,
it takes about four minutes.
     1. If pods restart more than twice, roll back.
* Check the queue depth afterwards.

## Prod

### Summary
Prod deploys are manual and need a second pair of eyes.

### Example

* Announce in the channel.

```shell
paycli deploy --env=prod --service=payments
```

* Wait for the canary.

## Environments

Env     | Region      | Owner | Notes                                                                                                              | Dashboard
------- | ----------- | ----- | ------------------------------------------------------------------------------------------------------------------ | ---------
staging | us-central1 | us    |                                                                                                                     | [link](https://dashboards.example.com/payments/staging/overview/detail)
prod    | us-central1 | us    | Deploys are manual and need a second reviewer, see above. Also the canary takes ten minutes so do not start at 17:00. | [link](https://dashboards.example.com/payments/prod/overview/detail)

<details>
<summary>Old rollback procedure</summary>
We used to roll back by hand. Do not do this any more.
</details>

# Contacts

See [../../teams/payments/oncall.md](../../teams/payments/oncall.md) for the rotation.
