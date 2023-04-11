# <a id="top"></a>VSCode

## Configuration sample

```yaml
# Configure with list, where item[N].owner is username or user object
vscode_users_exts:
  - owner: "{{ factum.ctl_user }}"
    exts:
      - bbenoist.vagrant
      - dotiful.dotfiles-syntax-highlighting
      - eamodio.gitlens
      - editorconfig.editorconfig
      - golang.go
      - liximomo.sftp
      - leizongmin.node-module-intellisense
      - mjmcloug.vscode-elixir
      - ms-azuretools.vscode-docker
      - ms-vscode-remote.vscode-remote-extensionpack
      - redhat.ansible
      - tomaciazek.ansible
      - wholroyd.jinja
```

```yaml
vscode_users_exts: '{{
    [{
      "owner": "some-user",
      "exts": [
        "azuretools.vscode-docker",
        "redhat.ansible",
      ],
    }] + (
      factum.target_users_obj | dict2items(key_name="exts", value_name="owner")
      | map("combine", {
        "exts": [
          "editorconfig.editorconfig",
          "redhat.ansible",
        ],
      },
    ))
  }}'
```

[To top]

[To top]: #top
