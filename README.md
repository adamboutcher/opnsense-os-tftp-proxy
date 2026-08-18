# opnsense-os-tftp-proxy

## Installation

### Install from the OPNsense UI

1. Open **System → Firmware → Plugins**.
2. Search for **os-tftp-proxy**.
3. Click **Install** and wait for the installation to complete.
4. Go to **Services → TFTP Proxy** to configure and enable it.

### Install from the shell

```sh
pkg install os-tftp-proxy
```

After installation, configure the plugin in **Services → TFTP Proxy**.