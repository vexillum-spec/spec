@echo off
rem agent_start: prepare an isolated worktree for this issue's branch.
rem Environment from the runner: CC_ISSUE_BRANCH, CC_BASE_BRANCH, CC_ISSUE_WORKTREE.
if exist "%CC_ISSUE_WORKTREE%" (
  echo Worktree already exists: %CC_ISSUE_WORKTREE%
  exit /b 0
)
git show-ref --verify --quiet "refs/heads/%CC_ISSUE_BRANCH%"
if %errorlevel%==0 (
  git worktree add "%CC_ISSUE_WORKTREE%" "%CC_ISSUE_BRANCH%" || exit /b 1
) else (
  git worktree add -b "%CC_ISSUE_BRANCH%" "%CC_ISSUE_WORKTREE%" "%CC_BASE_BRANCH%" || exit /b 1
)
echo Prepared worktree for %CC_ISSUE_BRANCH%
