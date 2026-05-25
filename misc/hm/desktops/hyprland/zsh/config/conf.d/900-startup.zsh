# Run macchina on each gradfather shell session
if [ "$SHLVL" = "1" ]
then
  macchina
fi

# zoxide
eval "$(zoxide init zsh)"

# direnv
eval "$(direnv hook zsh)"

# atuin
eval "$(atuin init zsh)"
