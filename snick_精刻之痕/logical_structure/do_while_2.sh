# file: do_while.sh

list_me=""

read_me="
a
b
c
d
1
2
3
4
"

function get_value() {
  echo "read_me is: [$read_me]"
  echo "$read_me" | while read item
  do
    echo "------------"
    echo "current is: $item"
    list_me="$list_me $item"
  done

  #test
  #list_me="1 2 3"
}

function show_value() {
  for i in $list_me
  do
    echo "--> $i"
  done
}

get_value
show_value

# finished
