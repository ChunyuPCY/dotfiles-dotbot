# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
set -gx XDG_CONFIG_HOME "$HOME/.config" # 配置文件
set -gx XDG_CACHE_HOME "$HOME/.cache" # 非必要缓存数据
set -gx XDG_DATA_HOME "$HOME/.local/share" # 重要可移植数据
set -gx XDG_STATE_HOME "$HOME/.local/state" # 持久化非可移植数据
