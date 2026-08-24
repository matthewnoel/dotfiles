# Aliases
alias status='git status && git branch'
alias ls='ls -la'
alias zshrc='zed ~/.zshrc'
alias notes='zed --new-window ~/Desktop/today.md'
alias restore='git restore . && git clean -fd'
alias node-default='nvm alias default $(nvm current)'

function get_main_branch {
  local remote=$(git remote)
  local main_branch=$(git remote show $remote | sed -n '/HEAD branch/s/.*: //p')
  echo $main_branch
}

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
  local main_branch=$(get_main_branch)
  if [ "$current_branch" != "$main_branch" ]; then
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
  local main_branch=$(get_main_branch)
  if [ "$branch" = "$main_branch" ]; then
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
  local main_branch=$(get_main_branch)
  if [ "$branch" = "$main_branch" ]; then
    echo "Cannot clean up the main branch."
    git branch
    return
  fi

  git checkout "$main_branch"
  git branch -D "$branch"
  git pull
  eval status
}

function resolve_all {
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

  local branches=$(git branch --format="%(refname:short)")
  local array_of_branches=(${(f)branches})
  echo "Branches in the repository:"
  for branch in $array_of_branches; do
    if [ "$branch" = "$(get_main_branch)" ]; then
      continue
    fi
    git checkout "$branch"
    resolve_work
    echo "Resolved branch '$branch'."
  done
}

function main {
  git checkout "$(get_main_branch)"
}

function tree {
  local name=$1
  if [ -z "$name" ]; then
    echo "Cannot find worktree without a name."
    return
  fi

  local is_in_repository=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [ "$is_in_repository" != "true" ]; then
    echo "Cannot find worktree if the current directory is not a git repository."
    return
  fi

  local worktree_path=$(git worktree list --porcelain | awk -v name="$name" '
    /^worktree / { path=$2 }
    /^branch / {
      branch=$2
      sub("^refs/heads/", "", branch)
      if (branch == name) { print path; exit }
    }
  ')
  if [ -z "$worktree_path" ]; then
    echo "No worktree found matching '$name'."
    return
  fi

  echo "Changing directory to '$worktree_path'."
  cd "$worktree_path"
}

function issues {
  local max_title=$(( ${COLUMNS:-100} - 12 ))
  if [ "$max_title" -lt 40 ]; then
    max_title=40
  fi

  local owners
  owners=($(gh api user --jq '.login') $(gh api user/orgs --paginate --jq '.[].login'))
  if [ ${#owners[@]} -eq 0 ]; then
    echo "Cannot list issues without a working 'gh' login."
    return
  fi
  echo "Owners: ${owners[*]}"

  local owner_flags=()
  local owner
  for owner in $owners; do
    owner_flags+=(--owner "$owner")
  done

  local open_issues
  open_issues=$(gh search issues \
    $owner_flags \
    --state open \
    --archived=false \
    --limit 1000 \
    --json repository,number,title \
    --jq '.[] | [.repository.nameWithOwner, .number, .title] | @tsv')
  if [ $? -ne 0 ]; then
    echo "Cannot list issues if the search fails."
    return
  fi

  if [ -z "$open_issues" ]; then
    echo "No open issues found."
    return
  fi

  echo "$open_issues" | sort -t $'\t' -k1,1 -k2,2nr | awk -F '\t' -v max="$max_title" '
    $1 != repo {
      repo = $1
      printf "\n\033[1;34m%s\033[0m\n", repo
    }
    {
      title = $3
      if (length(title) > max) {
        title = substr(title, 1, max - 1) "\xe2\x80\xa6"
      }
      printf "  \033[33m#%-5s\033[0m %s\n", $2, title
    }
    END { printf "\n" }
  '
}

# Self-update dotfiles in the background
(git -C ~/dotfiles pull --quiet &>/dev/null &)
