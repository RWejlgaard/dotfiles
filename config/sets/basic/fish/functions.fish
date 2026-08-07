# Replicate the behavior of `!!` in bash
function last_history_item
    echo $history[1]
end
abbr -a !! --position anywhere --function last_history_item

# lookup various commands/syntax in a pinch
function cheat --description "help <field> <topic>"
	set args (echo $argv[2..-1] | tr ' ' '+')
	curl "cht.sh/$argv[1]/$args"
end

# update the default branch and create a fresh branch with value: $1
function gitissue
  if test -z "$argv[1]"
    echo "usage: gitissue <branch-name>"
    return 1
  end
  # Detect the remote's default branch instead of assuming `master`,
  # so this works on repos that use `main` (or anything else).
  set -l default (git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace 'origin/' '')
  if test -z "$default"
    echo "Could not determine origin's default branch; run 'git remote set-head origin -a' first."
    return 1
  end
  # `git reset --hard` discards uncommitted work, so confirm first.
  if not git diff --quiet; or not git diff --cached --quiet
    read -P "Uncommitted changes will be DISCARDED. Continue? [y/N] " -n 1 reply
    if test "$reply" != y -a "$reply" != Y
      echo "Aborted."
      return 1
    end
  end
  git reset --hard
  git checkout $default
  git pull origin $default
  git checkout -b $argv[1]
end
