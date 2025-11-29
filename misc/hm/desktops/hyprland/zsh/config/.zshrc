# Timezsh start
if [ -n "${ZSH_DEBUGRC+1}" ]; then zmodload zsh/zprof; fi

# Ensuring Zap installed
[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] &&
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Loading config files
for FILE in $(find "$ZDOTDIR/conf.d/" -type l -name '*.zsh' -exec basename {} \; | sort -n); do
  source "$ZDOTDIR/conf.d/$FILE"
done

plug "zsh-users/zsh-autosuggestions"
plug "agkozak/agkozak-zsh-prompt"
plug "zsh-users/zsh-completions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"
plug "arzzen/calc.plugin.zsh"
plug "jeffreytse/zsh-vi-mode"
plug "TunaCuma/zsh-vi-man"
plug "wazum/zsh-directory-dot-expansion"
plug "hlissner/zsh-autopair"
plug "kutsan/zsh-system-clipboard"

# Adding local completions to fpath
fpath+=($ZDOTDIR/completions)

autoload -Uz compinit
_comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
# #q expands globs in conditional expressions
if [[ $_comp_path(#qNmh-20) ]]; then
  # -C (skip function check) implies -i (skip security check).
  compinit -C -d "$_comp_path"
else
  mkdir -p "$_comp_path:h"
  compinit -i -d "$_comp_path"
  # Keep $_comp_path younger than cache time even if it isn't regenerated.
  touch "$_comp_path"
fi
unset _comp_path

# Timezsh end
if [ -n "${ZSH_DEBUGRC+1}" ]; then zprof; fi
