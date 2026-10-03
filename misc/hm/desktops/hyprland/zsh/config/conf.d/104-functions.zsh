function note() {
  local NAME="$1"
  local FILE_PATH=$(find "~/Documents/notes" -type f -iname "$NAME*.md")
  if [ -f "$FILE_PATH" ]; then
    $EDITOR "$FILE_PATH"
  else
    echo 'target file not found!'
    return 1
  fi
}

function fkill {
  local PIDS=$(
  LIBPROC_HIDE_KERNEL= ps -aux |
    fzf --bind 'ctrl-r:reload(ps -ef)' --header 'Press CTRL-R to reload' \
        --header-lines=1 --layout=reverse -m |
    awk '{print $2}'
  );

  for PROC_ID in $(<<< $PIDS)
  do
    kill -s KILL $PROC_ID
  done
}

function fopen {
  local FILE=$(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")
  if [ -f "$FILE" ];then
    xdg-open "$FILE"
  fi

}

# Extract files
function extract { 
  if [ -f $1 ] ; then 
    case $1 in 
      *.tar.bz2)   tar xjf $1     ;; 
      *.tar.gz)    tar xzf $1     ;; 
      *.bz2)       bunzip2 $1     ;; 
      *.rar)       unrar x $1     ;; 
      *.gz)        gunzip $1      ;; 
      *.tar)       tar xf $1      ;; 
      *.tbz2)      tar xjf $1     ;; 
      *.tgz)       tar xzf $1     ;; 
      *.zip)       unzip $1       ;; 
      *.Z)         uncompress $1  ;; 
      *.7z)        7z x $1        ;; 
      *)     echo "'$1' cannot be extracted via extract()" ;; 
       esac 
   else 
       echo "'$1' is not a valid file" 
   fi 
}
