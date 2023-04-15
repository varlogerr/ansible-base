# <a id="top"></a>Git

* [Configuration sample](#configuration-sample)

## Configuration sample

Conffiles that end with '.j2' extension will be treated as templates and then you can pass variables to them that will be available in `tpl_vars` variable

```yaml
# Configure with list, where item[N].owner is username or user object
git_users_extraconfs:
  #
  # `factum.ctl_user` user configurations
  #
  - owner: '{{ factum.ctl_user }}'
    src: '{{ factum.book.core_home }}/resources/conf/git/extra.ini.j2'
    tpl_vars: # optional
      git_user_name: Noname
      git_user_email: noname@nowhere.com
```

```yaml
# Deploy to `factum.root_user_obj.name` and 
git_users_extraconfs: '{{
    [{
      "owner": factum.root_user_obj.name,
      "src": factum.book.core_home + "/resources/conf/git/extra.ini.j2",
      "tpl_vars": {
        "git_user_name": factum.root_user_obj.name,
        "git_user_email": factum.root_user_obj.name + "@gmail.com",
      },
    }] + (
      {
        factum.ctl_user: factum.ctl_user_obj,
      } | dict2items(key_name="src", value_name="owner") | map("combine", {
        "src": factum.book.core_home + "/resources/conf/git/extra.ini.j2",
        "tpl_vars": {
          "git_user_name": factum.ctl_user,
          "git_user_email": factum.ctl_user + "@gmail.com",
        },
      },
    ))
  }}'
```

[To top]

[To top]: #top
