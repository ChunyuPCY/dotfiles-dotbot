# dotfiles-dotbot

使用 [dotbot](https://github.com/anishathalye/dotbot) 管理我的 dotfiles，
使用 [age](https://age-encryption.org/) 加密处理

## Clone

1. 拉取

   ```sh
    # 克隆时同时初始化并拉取所有 submodule
    git clone <git@github.com>:ChunyuPCY/dotfiles-dotbot.git ~/.dotfiles
   ```

1. 复制 `age` 加密 age

   ```sh
   cd ~/.dotfiles
   # Copy age.key from a secure location (password manager, USB key, etc.)
   cp /secure/location/age.key encrypted/age.key
   ./install
   ```

## Workflow
