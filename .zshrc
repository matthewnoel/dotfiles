alias status='git status && git branch'
alias notes='code ~/Desktop/today.md'
alias ls='ls -la'

function start_work {
  local branch=$1
  echo "Parameter Branch '$branch'."
  local sanitized_branch=$(echo "$branch" | sed 's/\s\+/-/g')
  echo "Sanitized Branch '$sanitized_branch'."
  if [ -z "$sanitized_branch" ]; then
    echo "Cannot start without branch name."
    return
  fi

  local is_in_repository=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [ "$is_in_repository" != "true" ]; then
    echo "Cannot start if the current directory is not a git repository."
    return
  fi

  local git_status=$(git status -s)
  echo "Current status: $git_status"
  if [ -n "$git_status" ]; then
    echo "Cannot start if there are current changes."
    git status -s
    return
  fi

  local current_branch=$(git branch --show-current)
  echo "Current branch: '$current_branch'."
  if [ "$current_branch" != "main" ]; then
    echo "Cannot start if not on main branch."
    git branch
    return
  fi

  git pull
  git checkout -b "$sanitized_branch"
  git branch
}

function push_work {
  local commit_message=$1

  local is_in_repository=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [ "$is_in_repository" != "true" ]; then
    echo "Cannot push code if the current directory is not a git repository."
    return
  fi

  local git_status=$(git status -s)
  echo "Current status: $git_status"
  if [ -z "$git_status" ]; then
    echo "Cannot push code if there are no current changes."
    git status -s
    return
  fi

  local branch=$(git branch --show-current)
  echo "Current branch: '$branch'."
  if [ "$branch" = "main" ]; then
    echo "Pushing from the main branch is not supported in this workflow."
    git branch
    return
  fi

  if [ -z "$commit_message" ]; then
    echo "Cannot push code without a commit message."
    return
  fi

  local add='git add .'
  local commit="git commit -m \"$commit_message\""
  local push="git push -u origin $branch"

  echo "Running: $add"
  eval $add
  echo "Running: $commit"
  eval $commit
  echo "Running: $push"
  eval $push
}

function resolve_work {
  local is_in_repository=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [ "$is_in_repository" != "true" ]; then
    echo "Cannot clean branch if the current directory is not a git repository."
    return
  fi

  local git_status=$(git status -s)
  echo "Current status: $git_status"
  if [ -n "$git_status" ]; then
    echo "Cannot clean branch if there are current changes."
    git status -s
    return
  fi

  local branch=$(git branch --show-current)
  echo "Current branch: '$branch'."
  if [ "$branch" = "main" ]; then
    echo "Cannot clean up the main branch."
    git branch
    return
  fi

  git checkout main
  git branch -D "$branch"
  git pull
  echo "Status"
}
