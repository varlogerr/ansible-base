# <a id="top"></a>`mount-cifs`

* [Configuration sample](#configuration-sample)

## Configuration sample

```yaml
# Comes with predefined `dump` and `pass` set to 0
mount_cifs_mounts:
  - fs: //127.0.0.1/Share1
    mp: /mnt/share1
    # user object or username, defaults to root
    mp_owner:
    # defaults to omitted
    mp_mode:
    # defaults to ext4
    type:
    # already included options:
    # * _netdev
    # * credentials=...
    # * iocharset=utf8
    # * nofail
    # * uid='{{ mount_cifs_mounts[N].mp_owner.uid }}'
    # * gid='{{ mount_cifs_mounts[N].mp_owner.gid }}'
    # * x-systemd.automount
    # * x-systemd.device-timeout=3s
    options:
      # - x-systemd.requires-mounts-for={some mount point}
    # share username
    username:
    # username password
    password:
```

[To top]

[To top]: #top
