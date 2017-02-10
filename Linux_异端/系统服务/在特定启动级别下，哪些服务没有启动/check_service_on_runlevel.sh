# check service status identified by Linux runlevel

# variables
num_runlevel=$1
list_service_not_running=""

for item_service in `chkconfig --list | grep --color "$num_runlevel:on" | awk '{print $1}'`
do

  echo "========================="
  echo "service name is: $item_service"

  echo "---------"
  echo "service status:"

  service $item_service status

  service_result_num=$?

  echo "### result number is: $service_result_num"

  if [ $service_result_num != "0" ]
  then
    echo "---> service not running"
    #list_service_not_running="$list_service_not_running|$item_service"
    list_service_not_running="$list_service_not_running $item_service"
  fi

  echo ""

done

echo ""
echo "========================="
echo "RUN LEVEL: $num_runlevel"
echo ""
echo "service not run:"
echo $list_service_not_running

echo "*****************"
echo "Done: "`date "+|%Y-%m-%d|%H:%M:%S|"`
