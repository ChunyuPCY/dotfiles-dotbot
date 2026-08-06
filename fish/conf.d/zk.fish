# zk 笔记工具快捷方式
# 固定笔记库路径，避免 auto-discovery 误认其他目录（曾误把 ~/Documents 当笔记库）
set -g ZK_NOTEBOOK_DIR "$HOME/Documents/notebook"

# 主命令：固定 notebook，任意目录可用
alias zkn 'zk --notebook-dir "$ZK_NOTEBOOK_DIR"'

# 常用快捷方式
alias zknew 'zkn new "$ZK_NOTEBOOK_DIR"'   # 新建笔记:  zknew --title "标题"（固定创建到笔记库）
alias zkl 'zkn list'                        # 列出笔记:  zkl -t 标签 / -m 关键词
alias zkf 'zkn edit --interactive'          # fzf 模糊搜索并编辑（最高频）
alias zkg 'zkn graph -f json > graph.json'  # 导出关系图
alias zkt 'zkn tag list'                    # 查看所有标签
