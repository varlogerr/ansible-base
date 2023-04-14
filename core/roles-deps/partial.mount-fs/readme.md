# <a id="top"></a>`partial.mount-fs`

* [Configuration sample](#configuration-sample)

## Configuration sample

```yaml
# Comes with predefined `dump` and `pass` set to 0
- name: Mount FS
  ansible.builtin.include_role: name=partial.mount-fs
  vars:
    mount_fs_mounts:
      - fs: UUID=...
        mp: /mnt/disk1
        # user object or username, defaults to root
        mp_owner:
        # defaults to omitted
        mp_mode:
        # defaults to ext4
        type:
        options:
    mount_fs_marker: 'Some marker for entries block'
```

[To top]

[To top]: #top
