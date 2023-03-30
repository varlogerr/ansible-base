# <a id="top"></a>TOC

* [Description](#description)
* [Core](#project-core)
  * [Fetch](#project-core-fetch)
  * [Update](#project-core-update)
* [Project](#project)
  * [Fetch](#project-fetch)
  * [Refetch playbook](#project-refetch-playbook)
* [Prerequisites](#prerequisites)
  * [Control machine](#prerequisites-control-machine)
  * [Target machine](#prerequisites-target-machine)
---

## Description

This framework is meant for quick ansible project scaffolding.

[To top]

## Project core

[Project core info](core/readme.md)

[To top]

### <a id="project-core-fetch"></a>Fetch

* change `branch` variable value (defaults to `master`) to fetch the core from a different branch.
* substitute `{CORE_DEST}` with your desired destination directory. Defaults to PWD.

```sh
(branch=master; bash <(
  dl_url=https://raw.githubusercontent.com/varlogerr/ansible-base/${branch}/core/fetch.sh
  curl -fsL -o - "${dl_url}" 2>/dev/null || wget -qO- "${dl_url}"
) [-b|--branch "${branch}"] [{CORE_DEST}])
```

[To top]

### <a id="project-core-update"></a>Update

* substitute `{BRANCH}` with your desired branch. Defaults to `master`.
* substitute `{CORE_DEST}` with your desired destination directory. Defaults to the actual core directory.

```sh
{CORE_DEST}/system/bin/fetch-core.sh [-b|--branch {BRANCH}] [{CORE_DEST}]
```

[To top]

## Project

[Project info](project/readme.md)

[To top]

### <a id="project-fetch"></a>Fetch

* substitute `{BRANCH}` with your desired branch. Defaults to `master`.
* substitute `{PROJ_DEST}` with your desired destination directory. Defaults to PWD.

```sh
{CORE_DEST}/system/bin/fetch-project.sh [-b|--branch {BRANCH}] [{PROJ_DEST}]
```

and follow **AFTER FETCH** instructions.

Issue `{CORE_DEST}/system/bin/fetch-project.sh -h` to view **AFTER FETCH** instructions again.

[To top]

### <a id="project-refetch-playbook"></a>Refetch playbook

* substitute `{BRANCH}` with your desired branch. Defaults to `master`.
* substitute `{CORE_DEST}` with your desired destination directory. Defaults to PWD.

```sh
{CORE_DEST}/system/bin/fetch-project.sh --book [-b|--branch {BRANCH}] [{PROJ_DEST}]
```

[To top]

## Prerequisites

[To top]

### <a id="prerequisites-control-machine"></a>Control machine

* ansible  
  [Installation instruction for different platforms](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)
* `sshpass` (optional, when ssh login is with password)

  ```sh
  # Debian with derivatives
  sudo apt update
  sudo apt install -y sshpass
  ```

  ```sh
  # RHEL with derivatives
  sudo dnf install -y sshpass
  ```

[To top]

### <a id="prerequisites-target-machine"></a>Target machine

* `python`
* `openssh-server`

```sh
# Debian with derivatives
sudo apt update
sudo apt install -y python3 openssh-server
```

```sh
# RHEL with derivatives
sudo dnf install -y python3 openssh-server
```

Optionally ansible control user can be created to be used for executing ansible tasks.

* Install dependencies

  ```sh
  # Debian with derivatives
  sudo apt update
  sudo apt install -y passwd
  ```

  ```sh
  # RHEL with derivatives
  sudo dnf install -y shadow-utils
  ```
* Create ansible control user

  ```sh
  # `-m` - create home directory
  # `-s` - set default shell
  # `-r` - (optional) make it system user 
  sudo useradd -m -s /bin/bash [-r] ansible-ctl
  ```
* Configure the user password

  ```sh
  sudo passwd ansible-ctl
  ```
* Make the user sudoer

  ```sh
  # Debian with derivatives
  sudo usermod -aG sudo ansible-ctl
  ```

  ```sh
  # RHEL with derivatives
  sudo usermod -aG wheel ansible-ctl
  ```

[To top]

[To top]: #top
