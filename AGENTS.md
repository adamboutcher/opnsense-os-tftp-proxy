# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this repo is

This repository is the source for `os-tftp-proxy`, an OPNsense plugin
package. It wraps the BSD `tftp-proxy(8)` binary (already present in the
OPNsense/FreeBSD base system at `/usr/libexec/tftp-proxy`) with:

- An OPNsense GUI page (**Services → TFTP Proxy**) for configuration.
- Automatic `pf(4)` anchor registration (`tftp-proxy/*` for `nat`, `rdr`,
  and `fw`) so TFTP data connections can pass through the firewall.
- An `inetd(8)`-managed service definition that starts the proxy on
  demand when a TFTP request arrives on the configured listen
  address/port.

There is no application build step, package manager, or test runner in
this repo — it is plugin *source* that gets built into a `.pkg` by
copying it into a checkout of the official
[opnsense/plugins](https://github.com/opnsense/plugins) tree and running
`make package` there (see below and `README.md`).

## Repository layout

```
net/tftp-proxy/
  Makefile              # Plugin metadata (name, version, maintainer) — see PLUGIN_VERSION
  pkg-descr             # Package description shown by pkg(8)
  src/
    etc/
      inc/plugins.inc.d/tftpproxy.inc   # Legacy PHP plugin hooks: firewall anchors, service registration
      rc.d/os-tftp-proxy                # rc.d start/stop/restart/status script (drives inetd)
    opnsense/
      mvc/app/
        controllers/OPNsense/TftpProxy/
          Api/ServiceController.php     # start/stop/restart/status API (extends ApiMutableServiceControllerBase)
          Api/SettingsController.php    # get/set config API
          IndexController.php           # renders the GUI page
          forms/general.xml             # form field definitions for the GUI
        models/OPNsense/TftpProxy/
          TftpProxy.php                 # model class
          TftpProxy.xml                 # config model schema (enabled, listenaddress, listenport, verbose)
          ACL/ACL.xml                   # access control list entry for the page
          Menu/Menu.xml                 # adds "Services → TFTP Proxy" menu item
        views/OPNsense/TftpProxy/index.volt  # Volt template for the GUI page
      service/
        conf/actions.d/actions_tftpproxy.conf   # configd actions (start/stop/restart/status)
        templates/OPNsense/TftpProxy/
          +TARGETS                      # template file list for configd template rendering
          inetd.conf.d                  # Jinja/Twig template rendering /etc/inetd.conf.d/tftp-proxy
          os-tftp-proxy                 # rendered into rc.conf.d for the enable flag
.github/workflows/release.yml           # CI: builds .pkg files for tagged releases via a FreeBSD VM
README.md                               # Manual build/install instructions for end users
```

## Conventions to follow

- **OPNsense plugin conventions, not generic PHP conventions.** Follow
  the patterns already used by the official
  [opnsense/plugins](https://github.com/opnsense/plugins) repo (e.g.
  `net/haproxy`, other small `net/` plugins) for anything new: MVC
  controller/model structure, `ApiMutableServiceControllerBase` for
  service control, `BaseModel` field types in XML models, ACL/Menu XML
  shape, etc.
- **Config model is the source of truth.** GUI fields, validation
  (regex/min/max), and defaults live in `TftpProxy.xml`. Keep
  `forms/general.xml` (GUI) and `TftpProxy.xml` (model) in sync when
  adding/removing a setting.
- **Templates render config into system files.** `inetd.conf.d` and
  `os-tftp-proxy` under `service/templates/` are configd/Twig templates,
  not static files — they reference `OPNsense.tftpproxy.general.*`
  helpers. Any new setting that needs to reach a system file must be
  wired through a template, not hardcoded.
- **Firewall anchors are registered in PHP, not pf syntax files.**
  `tftpproxy.inc`'s `tftpproxy_firewall()` calls `$fw->registerAnchor(...)`
  for `nat`/`rdr`/`fw`. Do not add anchors directly to a `.conf`/pf
  template.
- **Service lifecycle goes through inetd, not a long-running daemon.**
  `os-tftp-proxy` (rc.d) starts/stops the service by writing/removing
  `/etc/inetd.conf.d/tftp-proxy` and HUP-ing inetd — it does not exec the
  proxy binary directly. Preserve this pattern for any lifecycle changes.
- **BSD-style license headers.** Every PHP/shell source file carries a
  2-clause BSD copyright header (see existing files). Match that header
  verbatim (year/author) in new source files rather than inventing a new
  license block.
- **Bump `PLUGIN_VERSION` in `net/tftp-proxy/Makefile`** for any
  user-visible change, following the plugin's existing versioning (it is
  read directly by CI to name build artifacts).
- **IPv4 only.** `listenaddress` is validated as IPv4-only by design
  (see the regex and validation message in `TftpProxy.xml`); don't
  silently add IPv6 support without updating that validation and the
  README/pkg-descr claims.

## Building / testing changes

There is no local build/test tooling in this repo itself. To validate a
change end-to-end you need a FreeBSD build host with the official
`opnsense/plugins` tree, as described in `README.md`:

```sh
git clone https://github.com/opnsense/plugins.git
cp -R net/tftp-proxy /path/to/plugins/net/tftp-proxy
cd /path/to/plugins/net/tftp-proxy
make package
```

CI (`.github/workflows/release.yml`) does exactly this inside a FreeBSD
VM (via `vmactions/freebsd-vm`) against the `stable/26.1` and
`stable/26.7` `opnsense/plugins`/`opnsense/core` branches, for both a
tagged release and manual `workflow_dispatch`. When changing anything
that affects the build (Makefile, file layout, `+TARGETS`), sanity-check
against what that workflow does rather than assuming — there's no faster
local signal than reading it.

At minimum, before committing a change:

- Validate XML files are well-formed (`TftpProxy.xml`, `general.xml`,
  `ACL.xml`, `Menu.xml`) — OPNsense's MVC framework will fail silently or
  loudly on malformed model/form XML.
- Check PHP syntax on any changed `.php` file (`php -l <file>`) if a PHP
  interpreter is available.
- Re-read `tftpproxy.inc` and the rc.d script together when touching
  service start/stop logic — they must agree on the pidfile
  (`/var/run/inetd.pid`) and configd action names (`start`/`stop`/`restart`).

## Commit / PR notes

- Keep the BSD license headers and copyright years consistent with
  surrounding files.
- Update `README.md` and `pkg-descr` if user-facing behavior (install
  steps, feature description) changes.
- This plugin is not yet in the official OPNsense plugins repository, so
  there's no upstream review process to satisfy beyond this repo's own
  CI — but code should still be written as if it were being submitted
  upstream to `opnsense/plugins`, since that's the eventual goal.
