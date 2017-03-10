# file: do_while.sh

list_me=""

cursor_me="1"

function get_value(){
  while [ $cursor_me -lt 10 ]
  do
    list_me="$list_me $cursor_me"
    let "cursor_me++"
  done

}

#get_value

echo "# list [before] is:"
echo "$list_me"

echo ""

get_value

echo "# list [after] is:"
echo "$list_me"

# finished
