# `partial.deploy-app-autostart`

## Demo

```yml
- name: Deploy app autostart
  ansible.builtin.include_role: name=partial.deploy-app-autostart
  vars:
    desktop_app_autostart_file: {relative to role home path to autostart file}
    desktop_app_autostart_user: "{{ item }}"
  loop: {autostart users list}
  loop_control:
    label: "{{ (factum.users_obj[item] | default(item)).name }}"
```
