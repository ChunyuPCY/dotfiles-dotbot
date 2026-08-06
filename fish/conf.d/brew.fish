# Homebrew 国内镜像 (中科大 USTC)
# 说明: 阿里云镜像自 2025-08 起停止同步，改用 USTC (API/brew.git 与官方一致，bottle 实测 ~17MB/s)
set -gx HOMEBREW_API_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"
set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.ustc.edu.cn/brew.git"
# USTC 不再提供 homebrew-core 的 git 镜像（Homebrew 4+ 用 API 代替 core tap），
# 日常 install/upgrade 用不到 CORE_GIT_REMOTE，故不再设置，需要时 brew 会走官方源
# 跳过每次 install 前的自动 update，显著提速（需要更新时手动 brew update）
set -gx HOMEBREW_NO_AUTO_UPDATE 1
