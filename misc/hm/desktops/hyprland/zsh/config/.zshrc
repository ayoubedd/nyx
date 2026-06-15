# Timezsh start
if [ -n "${ZSH_DEBUGRC+1}" ]; then zmodload zsh/zprof; fi

# Ensuring Zap installed
[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] &&
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Loading config files
for FILE in "$ZDOTDIR/conf.d"/[0-9]*.zsh(Nn); do
  source "$FILE"
done

plug "reobin/typewritten"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-completions"
plug "zsh-users/zsh-syntax-highlighting"
plug "arzzen/calc.plugin.zsh"
plug "jeffreytse/zsh-vi-mode"
plug "TunaCuma/zsh-vi-man"
plug "wazum/zsh-directory-dot-expansion"
plug "hlissner/zsh-autopair"
plug "kutsan/zsh-system-clipboard"

local comp_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# Foreground Completion Initialization
autoload -Uz compinit
if [[ "$comp_dump"(#qNmh-20) ]]; then
  compinit -C -d "$comp_dump"
else
  mkdir -p "$comp_dump:h"
  compinit -i -d "$comp_dump"
  touch "$comp_dump"
fi

# Background Auto-Compilation (Silent, Non-blocking)
() {
  # Completely sever connection to the terminal tty
  exec 1>/dev/null 2>&1
  
  autoload -Uz zrecompile
  local -a configs
  
  # 1. Core dotfiles
  configs=( "$ZDOTDIR"/.z(shrc|shenv|profile)(N) )
  configs+=( "$ZDOTDIR/conf.d"/*.zsh(N) )
  
  # 2. Zap's core engine files
  configs+=( "$ZAP_DIR"/zap.zsh(N) )
  configs+=( "$ZAP_DIR"/functions/*(N.) )

  # 3. Lean Plugin Entry Files Only
  # This looks exactly inside each plugin folder for files matching the folder name
  local plugin_dir
  for plugin_dir in "$ZAP_DIR"/plugins/*(N/); do
    local name="${plugin_dir:t}" # Gets just the folder name (e.g., "zsh-autosuggestions")
    
    # Target only the specific entry file entry points
    configs+=( "$plugin_dir/$name.plugin.zsh"(N.) )
    configs+=( "$plugin_dir/$name.zsh"(N.) )
    configs+=( "$plugin_dir/$name.sh"(N.) )
    
    # Special fallback case: some plugins just use "plugin.zsh" or a generic name
    if [[ ! -f "$plugin_dir/$name.plugin.zsh" && ! -f "$plugin_dir/$name.zsh" ]]; then
      configs+=( "$plugin_dir"/*.plugin.zsh(N.) )
    fi
  done

  # 4. Run compile on the refined list
  local config
  for config in $configs; do
    zrecompile -p -q "$config"
  done
} >/dev/null 2>&1 &|

# Timezsh end
if [ -n "${ZSH_DEBUGRC+1}" ]; then zprof; fi
