alias jiraSquad='echo $(git_current_branch) | cut -d"-" -f1'
alias jiraNumber='echo $(git_current_branch) | cut -d"-" -f2'
alias repoName='git_repo_name'
alias currentBranch='git_current_branch'
alias JIRA='echo [$(jiraSquad)-$(jiraNumber)]'

SQUAD='@recarga/account-services'
LABELS='&labels=AccountServices,account-services'
GITHUB_URL="https:///github.com/recarga/"
JIRA_PR_URL="https://recargapay.atlassian.net/browse/"
BODY=$(printf "&body=%s\n\n%s" "$SQUAD" "$JIRA_PR_URL")

PR_BASE='$GITHUB_URL$(repoName)/compare/'
PR_SUFFIX='$(currentBranch)?expand=1&title='
COMMIT_INFO='[$(jiraSquad)-$(jiraNumber)] - $(git reflog -1 | sed "s/^.*: //")$BODY$(jiraSquad)-$(jiraNumber)$LABELS'

alias opendev='open -a "Google Chrome" "'$PR_BASE'dev...'$PR_SUFFIX'DEV - '$COMMIT_INFO'"'
alias openqa='open -a "Google Chrome" "'$PR_BASE'qa...'$PR_SUFFIX'QA - '$COMMIT_INFO'"'
alias openst='open -a "Google Chrome" "'$PR_BASE'staging...'$PR_SUFFIX'STAGING - '$COMMIT_INFO'"'
alias openprod='open -a "Google Chrome" "'$PR_BASE'$(git_main_branch)...'$PR_SUFFIX'PROD - '$COMMIT_INFO'"'

mkpr() {
  if [[ $# -gt 0 ]]; then
    git push origin $(git_current_branch) && buildUrl ${1}
  else
    git push origin $(git_current_branch) && opendev && openqa && openst && openprod
  fi
}

alias gmc='current=$(git_current_branch); git checkout staging && git pull --rebase --autostash && git checkout -b merge/$current && git merge $current'
alias gmcdev='current=$(git_current_branch); git branch -D dev && git pull --rebase --autostash && git checkout dev && git checkout -b merge/dev/$current && git merge $current'
alias gmcqa='current=$(git_current_branch); git checkout qa && git pull --rebase --autostash && git checkout -b merge/qa/$current && git merge $current'

alias gmm='gco staging && gupa && gcb merge/$(git_main_branch)-$(date +%Y-%m-%d_%H) && git merge origin $(git_main_branch)'
alias gmmdev='git branch -D dev && git checkout dev && git checkout -b merge/dev/$(git_main_branch)-$(date +%Y-%m-%d_%H) && git merge origin/$(git_main_branch)'
alias gmmqa='gco qa && gupa && gcb merge/qa/$(git_main_branch)-$(date +%Y-%m-%d_%H) && git merge origin $(git_main_branch)'
