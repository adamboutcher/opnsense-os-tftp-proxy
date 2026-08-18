# opnsense-os-tftp-proxy

## Installation

This plugin is **not yet published** in the official OPNsense plugins repository, so installation currently requires manual steps.

### Manual installation (current)

1. Set up an OPNsense plugins build environment.
2. Add this plugin source (`net/tftp-proxy`) into your local OPNsense plugins tree.
3. Build the `os-tftp-proxy` package in that environment.
4. Install the resulting package on your OPNsense system (for example with `pkg add` or through your own package repository).
5. Configure and enable it in **Services → TFTP Proxy**.