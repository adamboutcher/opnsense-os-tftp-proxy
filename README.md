# OPNsense Plugin: os-tftp-proxy

This plugin was developed using AI (Claude and Copilot).

## Installation

This plugin is **not yet published** in the official OPNsense plugins repository, so installation currently requires manual steps.

### Manual Install - Pre-Packaged

1. Download the `pkg` file for your OPNsense release from our [releases secion](https://github.com/adamboutcher/opnsense-os-tftp-proxy/releases).
2. Copy the `pkg` file to your OPNsense firewall (Or curl direct `curl -L -O <URL>`).
3. Install using the `pkg add` tool (as per below).

### Manual Install - Build

If you usually install plugins from **System → Firmware → Plugins**, this process is different:

- You cannot install this plugin directly from the standard plugin list yet.
- You must build a package first, then install that package on your firewall.

#### 1) Prepare a build host

Use a separate machine/VM (your **build host**) for building packages.  
Do not do this directly on your production firewall.

#### 2) Understand the "local plugins tree"

The **local plugins tree** is just a local checkout of the official OPNsense plugins source repository on your build host.

- It is a folder on disk you control (example: `~/opnsense/plugins`)
- It is **not** a folder that already exists on a default firewall install
- You create/access it by cloning the plugins repository on your build host
- Official plugins repository: https://github.com/opnsense/plugins

#### 3) Get the code onto your build host

On the build host, clone both repositories:

- official plugins tree (where packages are built from)
- this plugin repository (source you want to add)

Example:

```sh
mkdir -p ~/opnsense
cd ~/opnsense

git clone https://github.com/opnsense/plugins.git
git clone https://github.com/adamboutcher/opnsense-os-tftp-proxy.git
```

You can also download archives and extract them if you prefer not to use git.

#### 4) Add this plugin source to the plugins tree

Inside your local plugins tree checkout:

1. Ensure the `net/` category exists.
2. Copy this repository's `net/tftp-proxy` directory into that `net/` folder.
3. Confirm the resulting path is `net/tftp-proxy`.
4. Confirm that directory contains the plugin `Makefile` and `src/` subtree.

Example:

```sh
mkdir -p ~/opnsense/plugins/net
cp -R ~/opnsense/opnsense-os-tftp-proxy/net/tftp-proxy ~/opnsense/plugins/net/
ls ~/opnsense/plugins/net/tftp-proxy
```

#### 5) Build the package

Build `os-tftp-proxy` from inside the plugins tree on the build host.

Example:

```sh
cd ~/opnsense/plugins/net/tftp-proxy
make package
```

This creates an `os-tftp-proxy` package artifact that you can copy to your firewall.

#### 6) Install on OPNsense

Transfer the built package file to your OPNsense system, then install it using:

- `pkg add <package-file>`

If you maintain your own package repository, you can also publish it there and install via normal package workflows.

Installing this way (instead of through **System → Firmware → Plugins**) means OPNsense's config never records the plugin as explicitly installed, so it will show as `(misconfigured)` in the plugin list even though it works correctly. Clear that status with:

- `pkg set -A 1 os-tftp-proxy`

## Configuration

After installation, configure and enable the plugin in **Services → TFTP Proxy**, then add the firewall rules described below.

Enabling the service also enables and (re)starts the base system's `inetd(8)`
and adds an `includedir /etc/inetd.conf.d` line to `/etc/inetd.conf` if it
isn't already present — both are required for `inetd` to pick up
`tftp-proxy`'s on-demand listener, and neither is on by default on a stock
OPNsense/FreeBSD install.

FreeBSD's `inetd` resolves a service by name against `/etc/services` — it
has no `address:port` syntax for a service entry (that's an OpenBSD-only
extension some `tftp-proxy` documentation assumes). The plugin keeps a
matching `/etc/services` entry for your configured **Listen Port**
automatically, and applies **Listen Address** globally to `inetd` via
`inetd_flags="-a <address>"` (the only way `inetd` supports restricting its
bind address) — this affects any other `inetd`-managed service on the box,
which is fine as long as `tftp-proxy` is the only one in use.

## Firewall Rules

`tftp-proxy(8)` listens on a local UDP port (`127.0.0.1:6969` by default) and needs firewall
rules to get client traffic to it. Add the rules below.

### 1. NAT port forward — redirect incoming TFTP to the proxy

Go to **Firewall → NAT → Port Forward** and add a rule on the interface that receives TFTP
requests (usually WAN):

| Field | Value |
|---|---|
| Interface | WAN (or the interface facing your TFTP clients) |
| Protocol | UDP |
| Destination | The WAN address (or whichever IP your clients target) |
| Destination port range | TFTP (69) |
| Redirect target IP | Must match **Listen Address** in the TFTP Proxy settings (default `127.0.0.1`) |
| Redirect target port | Must match **Listen Port** in the TFTP Proxy settings (default `6969`) |
| Filter rule association | **Add associated filter rule** |

### 2. Pass rule — allow the redirected traffic in

Choosing "Add associated filter rule" above makes OPNsense create this for you. If you manage
rules manually instead, add one under **Firewall → Rules → \<interface\>**:

- Action: Pass
- Protocol: UDP
- Source: any (or restrict to known clients)
- Destination: the proxy's Listen Address/Port, e.g. `127.0.0.1:6969`
- Interface: same interface as the port forward above

### 3. Outbound rule — allow the proxy to reach the real TFTP server

`tftp-proxy` runs on the firewall itself and opens a new UDP connection to the real TFTP
server on the client's behalf. Default "allow all" outbound policies need no changes here.
If you run a restrictive floating/outbound rule set that blocks traffic sourced from the
firewall itself, add a rule allowing outbound UDP from the firewall to your TFTP server(s)
(or any, if the server address isn't fixed).

### Notes

- No manual rule is needed for the TFTP data channel itself (the random high UDP port
  negotiated per transfer) — `tftp-proxy` opens that dynamically on the client's behalf.
- If you change **Listen Address** or **Listen Port** in the plugin settings, update the
  redirect target in the NAT rule (and the pass rule, if manually managed) to match.
