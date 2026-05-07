#!/bin/bash
# Opens GitHub PR/issue reference (org/repo#123) under cursor in copy mode
cursor_x=$(tmux display-message -p '#{copy_cursor_x}')
cursor_y=$(tmux display-message -p '#{copy_cursor_y}')

# Capture entire pane buffer and extract the cursor line
line=$(tmux capture-pane -p -S - -E - | sed -n "$((cursor_y + 1))p")

# Extract the "word" around cursor_x using chars valid in org/repo#123
left="${line:0:$((cursor_x + 1))}"
right="${line:$cursor_x}"
word_left=$(echo "$left" | grep -oE '[A-Za-z0-9._/#-]+$' || true)
word_right=$(echo "$right" | grep -oE '^[A-Za-z0-9._/#-]+' || true)

# They overlap at cursor char, remove first char of word_right
[ -n "$word_right" ] && word_right="${word_right:1}"
word="${word_left}${word_right}"

if [[ "$word" =~ ([A-Za-z0-9._-]+/[A-Za-z0-9._-]+)#([0-9]+) ]]; then
  open "https://github.com/${BASH_REMATCH[1]}/pull/${BASH_REMATCH[2]}"
fi

tmux send-keys q
