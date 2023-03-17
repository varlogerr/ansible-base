# <a id="top"></a>Update package manager cache

* [Main](../../../readme.md)

Update package manager caches. In many cases it's very important to run this role before any package installation role is invoked. A good place would be to place it in the `pre-tasks` section:

```yaml
  # ...
  pre_tasks:
    # ... no package installation roles yet
  - include_role: { name: update-pm-cache, apply: { tags: [ always ] } }
    tags: [always]
  # ...
```

[To top]

[To top]: #top
