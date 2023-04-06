# <a id="top"></a>Ansible project

* [Main](../readme.md)
---
* [Description](#description)
* [Directory structure](#directory-structure)

## Description

Basic ansible project.

## Directory structure

```
.
├── .envar      # Envar directory
├── .etc        # Some settings files
├── .inc        # Can be used for includes and libs for binaries
├── bin         # Playbook binaries directory. The binaries from `{CORE_DEST}/bin` can
|               # be symlinked here. See `{CORE_DEST}/system/bin/fetch-project.sh -h`
|               # for details
├── group_vars
├── host_vars
├── resources   # This directory can optionally be used for for secrets, configs, etc.
├── roles       # Current project specific roles directory
├── @dev.sh     # Development environment envar file
├── ansible.cfg
├── hosts.yml
├── playbook.yml
├── project.conf  # Project configuration file
├── readme.md
├── requirements.yml
└── vault.pass  # Vault password file to be used
```

[To top]

[To top]: #top
