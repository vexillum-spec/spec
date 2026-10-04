#!/bin/sh
# arrival on the merge stage: merge the issue branch into the base branch,
# verify, and clean up the branch's worktree on every success path. A nonzero
# exit leaves the tree merge-aborted and hands the log to the Integrator
# (run_agent_on_failure).
set -e

merged() {
  # The worktree is scaffolding; the branch is the work. Remove the worktree,
  # keep the branch deletable only once it is merged.
  if [ -n "$CC_ISSUE_WORKTREE" ] && [ -d "$CC_ISSUE_WORKTREE" ]; then
    git worktree remove --force "$CC_ISSUE_WORKTREE" || true
    git worktree prune
  fi
  git branch -d "$CC_ISSUE_BRANCH" || true
}

git checkout "$CC_BASE_BRANCH"
if git merge --no-ff "$CC_ISSUE_BRANCH" -m "Merge $CC_ISSUE_BRANCH"; then
  if npm test; then
    merged
    echo "Merged and verified $CC_ISSUE_BRANCH"
    exit 0
  fi
  # Clean merge, failed verify: roll back to the pre-merge state.
  git reset --hard "HEAD@{1}"
  echo "Verification failed; merge rolled back" >&2
  exit 1
fi
git merge --abort
echo "Merge conflict on $CC_ISSUE_BRANCH" >&2
exit 1
