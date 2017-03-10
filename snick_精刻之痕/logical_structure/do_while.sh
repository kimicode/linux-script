# file: do_while.sh

list_me=""

cursor_me="1"

while [ $cursor_me -lt 10 ]
do
  list_me="$list_me $cursor_me"
  let "cursor_me++"
done

echo "# list is:"
echo "$list_me"

# finished
