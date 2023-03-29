# <a id="top"></a>`system-update-pm-cache`

* [Main](../../readme.md)
---

Update package manager caches. In many cases it's very important to run this role before any package installation role is invoked. A good place would be to place it in the `pre-tasks` section:

```yaml
  # ...
  pre_tasks:
    # ... no package installation roles yet
    - name: Update PM cache
      ansible.builtin.include_role: {name: system-update-pm-cache, apply: {tags: [always]}}
      tags: [always]
  # ...
```

[To top]

[To top]: #top
