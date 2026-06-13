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

# update master and create a branch with value: $1
function gitissue
  if test -z "$argv[1]"
    echo "usage: gitissue <branch-name>"
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
  git checkout master
  git pull origin master
  git branch $argv[1]
  git checkout $argv[1]
end
