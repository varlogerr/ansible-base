# <a id="top"></a>MPV

* [Configuration sample](#configuration-sample)

## Configuration sample

Conffiles that end with '.j2' extension will be treated as templates and then you can pass variables to them that will be available in `tpl_vars` variable

```yaml
# Conffile copy mode
mpv_conffile: "{{ factum.book.core_home }}/resources/conf/mpv/hq.conf"
```

```yaml
# Conffile template mode
mpv_conffile:
  src: '/some-path-to-file.conf.j2'
  tpl_vars: # optional
    var1: val1
```

[To top]

[To top]: #top
