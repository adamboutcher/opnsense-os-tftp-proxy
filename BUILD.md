# OPNsense os-tftp-proxy

## Package builds

This plugin can be built automatically in GitHub Actions when a GitHub release
is published.

The package target is OPNsense-version dependent because the resulting `.pkg`
has to match the underlying FreeBSD ABI and the matching `opnsense/core` /
`opnsense/plugins` branch.

The release workflow builds these targets:

- OPNsense 26.1 (`stable/26.1`, FreeBSD 14.3)
- OPNsense 26.7 (`stable/26.7`, FreeBSD 15.1)

Each published release gets one installable package per supported target.

For manual runs, the workflow also supports `workflow_dispatch` with a target
selector so a single OPNsense version can be built on demand.