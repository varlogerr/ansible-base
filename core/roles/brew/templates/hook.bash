eval $('{{ bin_dir | quote }}/brew' shellenv)

. '{{ install_dir | quote }}/completions/bash/brew'

if [[ "$(id -un)" != '{{ brew_login | quote }}' ]]; then
  alias brew='sudo -u "{{ brew_login | quote }}" -i "{{ bin_dir | quote }}/brew"'
fi
{% for alias in aliases %}
alias {{ alias | quote }}='sudo -u "{{ brew_login | quote }}" -i "{{ bin_dir | quote }}/brew"'
{% endfor %}
