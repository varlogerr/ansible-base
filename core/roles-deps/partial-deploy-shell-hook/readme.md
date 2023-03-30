# `pathadd-deploy`

## Demo

```yml
- name: Deploy shell hook
  ansible.builtin.include_role: name=partial-deploy-shell-hook
  vars:
    shell_hook_dest_dir: {dest directory}
    shell_hook_bin_dir: {binaries directory path}
    shell_hook_symlink_dest: {where to symlink the hooks}
    shell_hook_add_lines: {options list of lines to be added after pathadd, defaults to []}
    shell_hook_become: {optional become bool, defaults to true}
    shell_hook_become_user: {optional become user, defaults to omit}
```
