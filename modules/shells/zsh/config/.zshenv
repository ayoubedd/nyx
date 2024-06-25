export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export WORDCHARS=${WORDCHARS//\//}

# SSH Agent socket
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# Include volta in path
export VOLTA_HOME="$XDG_DATA_HOME/volta"

# Go path
export GOPATH="$XDG_DATA_HOME/go"
export GOCACHE="$XDG_CACHE_HOME/go"
export GOBIN="$GOPATH/bin"

# Cargo path
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Deno path
export DENO_DIR="$XDG_CACHE_HOME/deno"

export PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$GOBIN:$CARGO_HOME/bin:$VOLTA_HOME/bin:$PATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export VISUAL='vim'
  export EDITOR='vim'
else
  export VISUAL='nvim'
  export EDITOR='nvim'
fi

# Repl's History files
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export DENO_REPL_HISTORY="$XDG_CACHE_HOME/deno_repl_history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonstartup.py"

# Curl
export CURL_HOME="$XDG_CONFIG_HOME/curl"

export OVPN_ROOT="$HOME/Documents/fastvpn-ovpns"
export NOTES_PATH="$HOME/Documents/Notes"
