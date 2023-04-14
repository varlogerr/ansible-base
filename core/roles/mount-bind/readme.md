# <a id="top"></a>`mount-bind`

* [Configuration sample](#configuration-sample)

## Configuration sample

```yaml
# Comes with predefined `dump` and `pass` set to 0
mount_bind_mounts:
  - fs: /tmp
    mp: /mnt/tmp
    # user object or username, defaults to root
    mp_owner:
    # defaults to omitted
    mp_mode:
    # defaults to ext4
    type:
    # already included options:
    # * auto
    # * bind
    options:
      # - x-systemd.requires-mounts-for={some mount point}
      # - x-systemd.device-timeout=10s
```

[To top]

[To top]: #top
