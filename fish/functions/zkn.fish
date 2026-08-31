function zkn --description 'Interactively create a zk note: pick template + title'
    set -l tdir ~/.config/zk/templates

    # 1. Pick a template with live preview
    set -l file (printf '%s\n' "$tdir"/*.md \
        | fzf --prompt='Template> ' \
            --preview='bat --color=always --plain {}' \
            --preview-window=right:50%)
    test -n "$file"; or return 1
    set -l template (string replace -r '\.md$' '' (basename "$file"))

    # 2. Title
    read -P 'Title> ' -l title
    test -n "$title"; or return 1

    # 3. Target directory (empty = notebook root / group decides)
    read -P 'Directory (empty = auto)> ' -l dir

    set -l args
    test -n "$dir"; and set args $args "$dir"

    zk new $args --template="$template.md" --title="$title"
end
