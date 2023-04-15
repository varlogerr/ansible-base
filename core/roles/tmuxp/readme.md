# <a id="top"></a>Tmuxp

* [Links](#links)
* [Configuration sample](#configuration-sample)

## Links

* https://tmuxp.git-pull.com/configuration/examples.html
* https://leanpub.com/the-tao-of-tmux/read#window-layouts


## Configuration sample

Conffiles that end with '.j2' extension will be treated as templates and then you can pass variables to them that will be available in `tpl_vars` variable

```yaml
# Configure with list, where item[N].owner is username or user object
tmuxp_users_confs:
  #
  # `factum.ctl_user` user configurations
  #
  - owner: "{{ factum.ctl_user }}"
    src: "{{ factum.book.core_home }}/resources/conf/tmuxp/triple-quad.yaml.j2"
  # install to .tmuxp directory with 'test1.yaml' name
  - owner: "{{ factum.ctl_user }}"
    src: "{{ factum.book.core_home }}/resources/conf/tmuxp/triple-quad.yaml.j2"
    dest: test1.yaml # optional
  # install to .tmuxp directory with 'test2.yaml' name with vars passed
  - owner: "{{ factum.ctl_user }}"
    src: "{{ factum.book.core_home }}/resources/conf/tmuxp/triple-quad.yaml.j2"
    dest: test2.yaml # optional
    tpl_vars: # optional
      session_name: main
      window_name_triple: main
      window_name_quad: secondary
  #
  # `root` user configurations
  #
    # providing user object instead of just name
  - owner: "{{ factum.root_user }}"
    src: "{{ factum.book.core_home }}/resources/conf/tmuxp/triple-quad.yaml.j2"
```

```yaml
# Deploy `triple-quad` configuration to control user and `2x-triple` to all target users
tmuxp_users_confs: '{{
    [{
      "owner": factum.ctl_user,
      "src": factum.book.core_home + "/resources/conf/tmuxp/triple-quad.yaml.j2",
      "dest": "main.yml",
      "tpl_vars": {
        "session_name": "Main",
      },
    }] + (
      factum.target_users_obj | dict2items(key_name="src", value_name="owner")
      | map("combine", {
        "src": factum.book.core_home + "/resources/conf/tmuxp/2x-triple.yaml.j2",
        "dest": "second.yml"
      },
    ))
  }}'
```

[To top]

[To top]: #top
