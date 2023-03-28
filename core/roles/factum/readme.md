# <a id="top"></a>`factum`

* [Main](../../readme.md)
---
* [Description](#description)
* [Factum values](#factum-values)
  * [Distro info](#factum-values-distro)
  * [Timezone info](#factum-values-timezone)
  * [Users info](#factum-values-users)
* [Usage demo](#usage-demo)

## Description

For some roles `factum` role comes as a prerequisite. It's not included as dependency into any of them, so it's highly recommended to add it to each playbook as the very first pre-task.

```yaml
  # ...
  pre_tasks:
    - name: Collect factum
      ansible.builtin.include_role: {name: factum, apply: {tags: [always]}}
      tags: [always]
  # ...
```

[To top]

## Factum values

[To top]

### <a id="factum-values-distro"></a>Distro info

```yaml
factum:
  #
  # ...
  #
  distro:
    # Distro id.
    # Example: 'linuxmint'
    id: ""
    # Distro id like. It also always includes the current distro id.
    # Example: ['debian', 'ubuntu', 'linuxmint']
    id_like: []
    # OS family.
    # Example: 'debian'
    family: ""
    # Distro version.
    # Example: '22.04'
    version: ""
    # Distro major version.
    # Example: '22'
    major_version: ""
    # OS architecture in AMD notation.
    # Example: 'amd64'
    arch: ""
    # Ubuntu code name for the current distro. Only available for
    # debian-based os family.
    # Example: 'focal'
    ubuntu_codename: ""
    # Ubuntu version for the current distro. Only available for
    # debian-based os family
    # Example: '22.04'
    ubuntu_version: ""
  #
  # ...
  #
```

[To top]

### <a id="factum-values-timezone"></a>Timezone info

```yaml
factum:
  #
  # ...
  #
  # Configured timezone.
  # Example: 'EET'
  tz: ""
  #
  # ...
  #
```

[To top]

### <a id="factum-values-users"></a>Users info

```yaml
# User object format:
#   gid:    # User group ID
#   group:  # User group name
#   home:   # User home directory
#   name:   # User name
#   uid:    # User ID

factum:
  #
  # ...
  #
  # Ansible control user name.
  ctl_user: ""
  # Ansible control user object (see 'User object format').
  ctl_user_obj: {}
  # List of target users names.
  target_users: []
  # Dict of target users objects (see 'User object format').
  # Format:
  #   username: user_object
  target_users_obj: {}
  # Root user object (see 'User object format')
  root_user_obj: {}
  # Skeleton user object (see 'User object format').
  # This is a pseudo user. It's the same as `root` with the
  # only difference that 'home' points to /etc/skel
  skel_user_obj: {}
  # List of target and root users names.
  users: []
  # Dict of target and root users objects (see 'User object format').
  # Format:
  #   username: user_object
  users_obj: {}
  #
  # ...
  #
```

[To top]

## Usage demo

```yaml
- name: Some task that works only in debian and redhat linux families
  {some_module}: {module_args}
  when:
    - factum.distro.family in ['debian', 'redhat']

- name: Some task that works only in debian
  {some_module}: {module_args}
  when:
    - factum.distro.id in ['debian']

- name: Some task that works only in debian and redhat or their derivatives
  {some_module}: {module_args}
  when:
    - factum.distro.id_like | intersect(['debian', 'redhat']) > 0
```

[To top]

[To top]: #top
