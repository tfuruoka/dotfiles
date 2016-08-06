#------------------------------
# General Settings
#------------------------------

## LANG
export LANG=utf-8
export LESSCHARSET=utf-8

## Auto completion by auto-fu.zsh
if [ -f ~/.zsh/auto-fu.zsh ]; then
    source ~/.zsh/auto-fu.zsh
    function zle-line-init () {
        auto-fu-init
    }
    zle -N zle-line-init
    zstyle ':completion:*' completer _oldlist _complete
fi

## Emacs keybind
bindkey -e

## Enable completion
autoload -U compinit
compinit -u

## Editor (vim)
export EDITOR=/usr/bin/vim

## Alias
alias la='ls -lah'

## History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history # share command history data

# ------------------------------
# Git Settings
# ------------------------------
## http://d.hatena.ne.jp/mollifier/20090814/p1
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%b)'
zstyle ':vcs_info:*' actionformats '(%b)[%a]'

precmd () {
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}

# ------------------------------
# Look And Feel Settings
# ------------------------------

export LSCOLORS=ExFxCxDxBxegedabagacad
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export ZLS_COLORS=$LS_COLORS
export CLICOLOR=true

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

### Prompt ###
# Color prompt
# http://www.sakito.com/2011/11/zsh.html
autoload -U colors; colors

# normal user
tmp_prompt="%{${fg[cyan]}%}%n%# %{${reset_color}%}"
tmp_prompt2="%{${fg[cyan]}%}%_> %{${reset_color}%}"
tmp_rprompt="%1(v|%F{magenta}%1v%f|)%{${fg[green]}%}[%(5~,%-2~/.../%2~,%~)]%{${reset_color}%}"
tmp_sprompt="%{${fg[yellow]}%}%r is correct? [Yes, No, Abort, Edit]:%{${reset_color}%}"

# root user
if [ ${UID} -eq 0 ]; then
  tmp_prompt="%B%U${tmp_prompt}%u%b"
  tmp_prompt2="%B%U${tmp_prompt2}%u%b"
  tmp_rprompt="%B%U${tmp_rprompt}%u%b"
  tmp_sprompt="%B%U${tmp_sprompt}%u%b"
fi

PROMPT=$tmp_prompt    # normal prompt
PROMPT2=$tmp_prompt2  # secondary prompt
RPROMPT=$tmp_rprompt  # right side prompt
SPROMPT=$tmp_sprompt  # prompt during correcting spell

PATH=/usr/local/bin:/usr/local/share:$PATH
export PATH

#------------------------------
# TMUX Settings
#------------------------------

## Start TMUX when zsh starts
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

        if is_tmux_runnning; then
            echo "${fg_bold[red]} _____ __  __ _   ___  __ ${reset_color}"
            echo "${fg_bold[red]}|_   _|  \/  | | | \ \/ / ${reset_color}"
            echo "${fg_bold[red]}  | | | |\/| | | | |\  /  ${reset_color}"
            echo "${fg_bold[red]}  | | | |  | | |_| |/  \  ${reset_color}"
            echo "${fg_bold[red]}  |_| |_|  |_|\___//_/\_\ ${reset_color}"
        elif is_screen_running; then
            echo "This is on screen."
        fi
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}

tmux_automatically_attach_session

## Logging during SSH
function ssh_tmux() {
  tmux  set-option default-terminal "screen" \; \
        run-shell	 "exec ssh $(echo $@)" \; \
        run-shell        "mkdir -p $HOME/.tmuxlog/#W/$(date +%Y-%m/%d)" \; \
        pipe-pane        "cat >> $HOME/.tmuxlog/#W/$(date +%Y-%m/%d/%H%M%S.log)" \; \
        display-message  "Started logging to $HOME/.tmuxlog/#W/$(date +%Y-%m/%d/%H%M%S.log)"
}
#        new-window -n $(echo $@) "exec ssh $(echo $@)" \; \

if [[ $TERM = screen ]] || [[ $TERM = screen-256color ]] ; then
  alias ssh=ssh_tmux
fi

#------------------------------
# Other settings
#------------------------------

## pyenv / rbenv settings for deli-adminpod-ansible
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(rbenv init -)"
