# <a id="top"></a>Ansible project core

* [Main](../readme.md)
---
* [Description](#description)
* [Supported platforms](#supported-platforms)
* [Directory structure](#directory-structure)
* [Important roles](#important-roles)
* [Issues](#issues)
  * [`cpu-x`](#issues-cpu-x)
  * [`upgrade` brew](#issues-upgrade-brew)
  * [`upgrade` nix](#issues-upgrade-nix)

## Description

Ansible project core. Contains the most basic and common binaries and roles.

Projects based on this core are best to be run with `core/bin` scripts instead of `ansible-playbook` command. The scripts from `core/bin` are already configured to use `ANSIBLE_ROLES_PATH` that includes all predefined directories.

[To top]

## Supported platforms

In theory should work fine with:

* AlmaLinux 8.*
* Debian 10.* and 11.*
* Ubuntu 18.04, 20.04 and 22.04 with derivatives

No guaranties at all. Roles are tested with:

* AlmaLinux 8.*
* Debian 11.*
* Linux Mint 21.*
* Ubuntu Server 22.04

[To top]

## Directory structure

```
.
├── bin         # Playbook binaries directory. The binaries can be symlinked to playbook
|               # projects. See `{CORE_DEST}/system/bin/fetch-project.sh -h` for details
├── roles       # Roles directory
├── roles-deps  # Dependency roles directory
└── system
    ├── bin     # System binaries directory. Contains fetch-* scripts
    └── inc     # Used for includes and libs of any kind
```

[To top]

## Important roles

* [`factum`](roles/factum/readme.md)
* [`system-update-pm-cache`](roles/system-update-pm-cache/readme.md)

[To top]

## Issues

* <a id="issues-cpu-x"></a>`cpu-x` role fails with error in AlmaLinux:

  > Error: Unable to find a match: cpu-x

  Currently disabled for `redhat` family.
  
  TODO: check the reason and other RHEL-based platforms.
* <a id="issues-upgrade-brew"></a>`upgrade` role doesn't support `brew` yet
* <a id="issues-upgrade-nix"></a>`upgrade` for `nix` is very memory greedy. Works fine on 4GB+ RAM, fails with 2GB

[To top]

[To top]: #top
