# opnsense-os-tftp-proxy

## Installation

This plugin is **not yet published** in the official OPNsense plugins repository, so installation currently requires manual steps.

### Manual installation (current)

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

#### 3) Get the code onto your build host

On the build host, clone both repositories:

- official plugins tree (where packages are built from)
- this plugin repository (source you want to add)

You can do this with `git clone`, or by downloading archives and extracting them.

#### 4) Add this plugin source to the plugins tree

Inside your local plugins tree checkout:

1. Ensure the `net/` category exists.
2. Copy this repository's `net/tftp-proxy` directory into that `net/` folder.
3. Confirm the resulting path is `net/tftp-proxy`.
4. Confirm that directory contains the plugin `Makefile` and `src/` subtree.

#### 5) Build the package

Build `os-tftp-proxy` using your OPNsense plugins build workflow on the build host.

#### 6) Install on OPNsense

Transfer the built package file to your OPNsense system, then install it using:

- `pkg add <package-file>`

If you maintain your own package repository, you can also publish it there and install via normal package workflows.

#### 7) Configure

After installation, configure and enable it in **Services → TFTP Proxy**.