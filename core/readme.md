# <a id="top"></a>Ansible project core

* [Main](../readme.md)
---
* [Description](#description)
* [Directory structure](#directory-structure)
* [Important roles](#important-roles)

## Description

Ansible project core. Contains the most basic and common binaries and roles.

Projects based on this core are best to be run with `core/bin` scripts instead of `ansible-playbook` command. The scripts from `core/bin` are already configured to use `ANSIBLE_ROLES_PATH` that includes all predefined directories.

[To top]

## Directory structure

```
.
├── bin         # Playbook binaries directory. The binaries can be symlinked to playbook
|               # projects. See `{CORE_DEST}/system/bin/fetch-project.sh -h` for details
├── roles       # User defined roles directory
└── system
    ├── bin     # System binaries directory. Contains fetch-* scripts
    ├── inc     # Used for includes and libs of any kind
    └── roles   # Some basic roles directory, that can be used in playbooks. Not for editing
```

[To top]

## Important roles

* [Update package manager cache](system/roles/update-pm-cache/readme.md)

[To top]

[To top]: #top
