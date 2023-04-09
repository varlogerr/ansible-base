# `partial.add-ppa`

## Demo

```yml
- name: Add repo
  ansible.builtin.include_role: name=partial.add-ppa
  vars:
    add_ppa_repo_name: {repo name}
    add_ppa_var_marker: {added ppa variable marker, optional, defaults to add_ppa_repo_name value}
    add_ppa_keyring: {keyreng file path}
    add_ppa_keys: {gpg keys list}
    add_ppa_repos: {repos list}
    add_ppa_once: {bool, only add once, optional, defaults to false}

- name: Deploy app autostart
  ansible.builtin.include_role: name=partial.deploy-app-autostart
  vars:
    desktop_app_autostart_file: {relative to role home path to autostart file}
    desktop_app_autostart_user: "{{ item }}"
  loop: {autostart users list}
  loop_control:
    label: "{{ (factum.users_obj[item] | default(item)).name }}"
```
