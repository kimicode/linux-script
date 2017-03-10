# file: char_in_list.sh

list_me="1 2 3 4 5"
char_a="6"
char_b="3"

if [[ "$list_me" =~ "$char_a" ]]
then
	echo "a is in the list."
else
	echo "a is not in the list."
fi

if [[ "$list_me" =~ "$char_b" ]]
then
	echo "b is in the list."
else
	echo "b is not in the list."
fi