#script_1="run_1.sh"
script_1="$1"

#script_2="run_2.sh"
script_2="$2"

# run script_1 and identify status
echo "*** running[1]: $script_1"
sh $script_1
if [ $? -eq 0 ]
  then
    echo " -- result: well"
    echo ""

    # run script_2 and identify status
    echo "*** running[2]: $script_2"
    sh $script_2
    if [ $? -eq 0 ]
      then
        echo " -- result: well"
        echo ""
      else
        echo " -- result: bad"
        echo ""
    fi
  else
    echo " -- result: bad"
    echo ""
fi
