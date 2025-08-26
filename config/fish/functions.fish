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
  git reset --hard
  git checkout master
  git pull origin master
  git branch $argv[1]
  git checkout $argv[1]
end
