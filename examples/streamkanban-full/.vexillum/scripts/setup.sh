#!/bin/sh
# agent_start: prepare an isolated worktree for this issue's branch, so
# parallel agents never collide in the main tree. Environment comes from the
# runner: CC_ISSUE_BRANCH, CC_BASE_BRANCH, CC_ISSUE_WORKTREE.
set -e
if [ -d "$CC_ISSUE_WORKTREE" ]; then
  echo "Worktree already exists: $CC_ISSUE_WORKTREE"
  exit 0
fi
if git show-ref --verify --quiet "refs/heads/$CC_ISSUE_BRANCH"; then
  git worktree add "$CC_ISSUE_WORKTREE" "$CC_ISSUE_BRANCH"
else
  git worktree add -b "$CC_ISSUE_BRANCH" "$CC_ISSUE_WORKTREE" "$CC_BASE_BRANCH"
fi
echo "Prepared worktree for $CC_ISSUE_BRANCH"
