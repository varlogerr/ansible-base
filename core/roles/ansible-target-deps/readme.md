# <a id="top"></a>`ansible-target-deps`

* [Main](../../readme.md)
---

Fix [Risks of becoming an unprivileged user](https://docs.ansible.com/ansible/2.10/user_guide/become.html#risks-of-becoming-an-unprivileged-user) issue.

In many cases it's very important to run this role before any package installation role is invoked. A good place for it would be in the `pre-tasks` section:

```yaml
  # ...
  pre_tasks:
    # ...
    - name: Setup ansible target deps
      ansible.builtin.include_role: {name: ansible-target-deps, apply: {tags: [always]}}
      tags: [always]
  # ...
```

[To top]

[To top]: #top
