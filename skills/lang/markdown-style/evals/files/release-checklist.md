# Release checklist

What to do before cutting a release of the payments service, in order. Follow it
end to end; the steps assume you already have prod access and a green pipeline.

[TOC]

## Freeze the branch

Announce the freeze in the team channel, then tag the release candidate:

```shell
paycli release tag --service=payments --candidate \
  --notes="$(git log --oneline "$LAST_TAG"..HEAD)"
```

Anything merged after the tag rides the next release.

## Verify the candidate

Run the full suite against staging and confirm the three signals below are flat
for at least fifteen minutes:

1.  Error rate, on the [service dashboard][dashboard].
2.  p99 latency, same dashboard.
3.  Queue depth, which lags the other two by about a minute.

[dashboard]: https://dashboards.example.com/payments/overview

## Cut the release

| Environment | Approvals | Canary |
|---|---|---|
| staging | none | 5 minutes |
| prod | one reviewer | 10 minutes |

Prod is deliberately slower: the canary window is what catches a bad migration
before it reaches every shard.

## See also

*   [Payments runbook](/docs/payments/runbook.md)
*   [Rollback procedure](/docs/payments/rollback.md)
