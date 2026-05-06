if status is-interactive
# Commands to run in interactive sessions can go here
end

# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
set -gx XDG_CONFIG_HOME "$HOME/.config"      # 配置文件
set -gx XDG_CACHE_HOME "$HOME/.cache"        # 非必要缓存数据
set -gx XDG_DATA_HOME "$HOME/.local/share"   # 重要可移植数据
set -gx XDG_STATE_HOME "$HOME/.local/state"  # 持久化非可移植数据

set -gx EDITOR "nvim"

# 主题设置 (Catppuccin Mocha)
set -gx THEME "catppuccin"
set -gx THEME_STYLE "mocha"

# fish theme
fish_config theme choose "$THEME-$THEME_STYLE"

# 配置 Homebrew 环境变量
eval (/opt/homebrew/bin/brew shellenv | string collect)

# 定义一个名为 proxy 的函数
function proxy_on
    set -x http_proxy http://127.0.0.1:7897
    set -x https_proxy http://127.0.0.1:7897
end

# 定义一个关闭代理的函数
function proxy_off
    set -e http_proxy
    set -e https_proxy
end

proxy_on

# Set up fzf key bindings
fzf --fish | source

# Set up zoxide
zoxide init fish | source

# Starship 配置
set -x STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship/config.toml"
set -x STARSHIP_THEME "$THEME"_"$THEME_STYLE"
# Set up starship
starship init fish | source
# 设置 Starship 主题配色
starship config palette $STARSHIP_THEME

# Set up bat
for word in $THEME $THEME_STYLE
    set -a bat_theme_parts (string upper (string sub -l 1 $word))(string sub -s 2 $word)
end

set -x BAT_THEME (echo "$THEME $THEME_STYLE" | python3 -c "import sys; print(sys.stdin.read().strip().title())")

# 加载私有配置（如果存在）
if test -f "$XDG_CONFIG_HOME/fish/private/api-key.fish"
    source "$XDG_CONFIG_HOME/fish/private/api-key.fish"
end

# fnm
fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell fish | source

# nvim
alias vi "NVIM_APPNAME=nvim-minimax nvim"

# cici
alias ciciconfig "git config user.name panchunyu;git config user.email panchunyu@chinacici.com"

# qoder
alias qoder 'open -a "Qoder"'

alias fup "source $XDG_CONFIG_HOME/fish/config.fish;echo fish updated!"

#
# --------------------- Eza (better ls) ---------------------
#
set -x EZA_CONFIG_DIR "$XDG_CONFIG_HOME/eza"
# 默认显示 icons：
alias ls "eza --icons"
# 显示文件目录详情
alias ll "eza --icons --long --header"
# 显示全部文件目录，包括隐藏文件
alias la "eza --icons --long --header --all"
# 显示详情的同时，附带 git 状态信息
alias lg "eza --icons --long --header --all --git"
# 替换 tree 命令
alias lt "eza --tree -L 2 --icons"
alias tree "eza --tree --icons"
# -----------------------------------------------------------

#------------------------------------------------------------
# yazi                                                      |
#------------------------------------------------------------
function y
  set tmp (mktemp -t "yazi-cwd.XXXXXX")
  command yazi $argv --cwd-file="$tmp"
  if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
    builtin cd -- "$cwd"
  end
  rm -f -- "$tmp"
end
# -----------------------------------------------------------



function fish_greeting
    fastfetch
end
