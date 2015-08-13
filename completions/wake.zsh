if [[ ! -o interactive ]]; then
    return
fi

compctl -K _wake wake

_wake() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(wake commands)"
  else
    completions="$(wake completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
