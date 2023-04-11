# `partial.copy-or-tpl`

`copy_or_tpl_src` that end with '.j2' extension will be treated as templates and then you can pass variables to them that will be available in `tpl_vars` variable

## Demo

```yml
- name: Deploy file or template
  ansible.builtin.include_role: name=partial.copy-or-tpl
  vars:
    copy_or_tpl_src: {sourc file}
    copy_or_tpl_dest: {destination file}
    copy_or_tpl_owner: {optional, user to act on behalf of (name or user object), defaults to root}
    copy_or_tpl_vars: {optional, vars to pass to template, {} by default}
    copy_or_tpl_dir_mode: {optional, dest directory mode, omitted by default}
    copy_or_tpl_file_mode: {optional, dest file mode, omitted by default}
```
