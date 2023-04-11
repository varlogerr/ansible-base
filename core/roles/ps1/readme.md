# <a id="top"></a>PS1

* [Configuration sample](#configuration-sample)

## Configuration sample

Conffiles that end with '.j2' extension will be treated as templates and then you can pass variables to them that will be available in `tpl_vars` variable

```yaml
# Conffile copy mode
ps1_src: '{{ factum.book.core_home }}/resources/conf/ps1/git.sh'
```

```yaml
# Conffile template mode
ps1_src:
  src: '/some-path-to-file.sh.j2'
  tpl_vars: # options
    var1: val1
```

[To top]

[To top]: #top
