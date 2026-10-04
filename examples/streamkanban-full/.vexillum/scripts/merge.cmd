@echo off
rem arrival on the merge stage: merge, verify, clean up the worktree on every
rem success path. Nonzero exit hands the log to the Integrator.
git checkout "%CC_BASE_BRANCH%" || exit /b 1
git merge --no-ff "%CC_ISSUE_BRANCH%" -m "Merge %CC_ISSUE_BRANCH%"
if errorlevel 1 (
  git merge --abort
  echo Merge conflict on %CC_ISSUE_BRANCH% 1>&2
  exit /b 1
)
call npm test
if errorlevel 1 (
  git reset --hard "HEAD@{1}"
  echo Verification failed; merge rolled back 1>&2
  exit /b 1
)
goto merged

:merged
if not "%CC_ISSUE_WORKTREE%"=="" if exist "%CC_ISSUE_WORKTREE%" (
  git worktree remove --force "%CC_ISSUE_WORKTREE%"
  git worktree prune
)
git branch -d "%CC_ISSUE_BRANCH%"
echo Merged and verified %CC_ISSUE_BRANCH%
exit /b 0
