# <a id="top"></a>Ansible project core

* [Main](../readme.md)
---
* [Description](#description)
* [Supported platforms](#supported-platforms)
* [Directory structure](#directory-structure)
* [Important roles](#important-roles)
* [TBD](#tbd)
* [Issues](#issues)
  * [`cpu-x`](#issues-cpu-x)
  * [`snapd`](#issues-snapd)
  * [`phpstorm`](#issues-phpstorm)
  * [`upgrade` nix](#issues-upgrade-nix)
  * ~~[`tmuxp`](#issues-tmuxp)~~

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

* [`ansible-target-deps`](roles/ansible-target-deps/readme.md)
* [`factum`](roles/factum/readme.md)
* [`system-update-pm-cache`](roles/system-update-pm-cache/readme.md)
* [`unettended-upgrades-rm`](roles/unettended-upgrades-rm/readme.md)

[To top]

## TBD

* add users extraconf configuration to `git` role
* create `git-ps1` role
* implement `tpm` support for `tmux` role
* create `tmux-user-config` role
* create `tmuxp-user-config` role
* validate desktop roles work in `rhel` and `debian`
* add `max-watches` as a dependency to vscode
* add `vscode-users-exts` functionality
* ~~`upgrade` role doesn't support `brew`~~

[To top]

## Issues

* <a id="issues-cpu-x"></a>`cpu-x` role fails with error in AlmaLinux:

  ```
  Error: Unable to find a match: cpu-x
  ```

  Currently disabled for `rhel` family.
  
  TODO: check the reason and other RHEL-based platforms.
* <a id="issues-snapd"></a>`snapd` fails to work in `almalinux` (not sure about other `rhel`-likes) with error:

  ```
  error: system does not fully support snapd: cannot mount squashfs image using "squashfs": mount:
  /tmp/syscheck-mountpoint-604945645: unknown filesystem type 'squashfs'.
  ```

  Currently disabled for `rhel` family.

  Solution: can be [isntalled manually](https://www.jetbrains.com/phpstorm/download/#section=linux)
* <a id="issues-phpstorm"></a>`phpstorm` fails to be installed in `almalinux` (not sure about other `rhel`-likes) due to dependency on `snap`

  Currently disabled for `rhel` family.
* <a id="issues-upgrade-nix"></a>`upgrade` for `nix` is very memory greedy. Works fine on 4GB+ RAM, fails with 2GB
* ~~<a id="issues-tmuxp"></a>`tmuxp` fails to work in `almalinux`, can be [installed manually with pip](https://github.com/tmux-python/tmuxp#installation)~~

  (fixed with installation via pip)

[To top]

[To top]: #top
