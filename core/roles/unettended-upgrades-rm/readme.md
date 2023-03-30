# <a id="top"></a>`unettended-upgrades-rm`

* [Main](../../readme.md)
---

Remove unattended-upgrades package. Unattended upgrades can break ansible playbook run process and I don't feel it's a good think anyways. A good place for it would be somewhere in the very top of `pre-tasks` section:

```yaml
  # ...
  pre_tasks:
    - name: Uninstall unettended upgrades
      ansible.builtin.include_role: {name: unettended-upgrades-rm, apply: {tags: [always]}}
      tags: [always]
  # ...
```

[To top]

[To top]: #top
