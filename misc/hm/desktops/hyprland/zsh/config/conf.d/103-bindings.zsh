zmodload zsh/complist

# edit command in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'e' edit-command-line

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Insert sudo before command
function insert_sudo() {
  zle beginning-of-line;
  zle -U 'sudo '
}
zle -N insert-sudo insert_sudo
bindkey '^x' insert-sudo

bindkey -M menuselect '?' history-incremental-search-forward
bindkey -M menuselect '/' history-incremental-search-backward

# Autosuggestions
bindkey -M viins '^ ' autosuggest-accept

bindkey -M vicmd yy zsh-system-clipboard-vicmd-vi-yank-whole-line
bindkey -M viopp y zsh-system-clipboard-vicmd-vi-yank

function yazi_shim() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

zle -N yazi_shim
bindkey -M vicmd f yazi_shim
