export ASDF_DATA_DIR="${ASDF_DATA_DIR:-${HOME}/.asdf}"

__iife() {
  unset __iife

  . '{{ src_dir }}/asdf.sh'
  . '{{ src_dir }}/completions/asdf.bash'
} && __iife
