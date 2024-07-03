# "agkozak/agkozak-zsh-prompt"
AGKOZAK_MULTILINE=0
AGKOZAK_LEFT_PROMPT_ONLY=1
AGKOZAK_PROMPT_DIRTRIM=2
AGKOZAK_BLANK_LINES=1
AGKOZAK_SHOW_STASH=1
AGKOZAK_SHOW_BG=1
AGKOZAK_BG_STRING='j'
AGKOZAK_COLORS_EXIT_STATUS=red
AGKOZAK_COLORS_USER_HOST=green
AGKOZAK_COLORS_PATH=blue
AGKOZAK_COLORS_BRANCH_STATUS=yellow
AGKOZAK_COLORS_PROMPT_CHAR=white      # Default text color
AGKOZAK_COLORS_CMD_EXEC_TIME=gray    # Default text color
AGKOZAK_COLORS_VIRTUALENV=green
AGKOZAK_COLORS_BG_STRING=magenta


# "zsh-users/zsh-history-substring-search"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=transparent,fg=green,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=transparent,fg=red,bold'
HISTORY_SUBSTRING_SEARCH_FUZZY=1
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_PREFIXED=1

# "zsh-users/zsh-autosuggestions"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
