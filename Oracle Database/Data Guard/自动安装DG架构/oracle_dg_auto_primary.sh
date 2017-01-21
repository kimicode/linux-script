# auto check oracle database instnace for DG structure master
# author: adamhuan
# blog: d-prototype.com

str_oracle_instance=$1

function say_hello(){
	echo "Script Name: Oracle_dg_auto_primary.sh"
	echo "Used for: Check and configuration"
	echo "+++++++++++++++++++++++"
	echo "Begin @"`date "+|%Y-%m-%d|%H:%M:%S|"`
	echo ""
}

function say_bye(){
	echo ""
	echo "+++++++++++++++++++++++"
	echo "Done @"`date "+|%Y-%m-%d|%H:%M:%S|"`
	echo ""
}

function check_oracle_database(){
	echo "Current Instance: $str_oracle_instance"
}
# Running:

say_hello

check_oracle_database

say_bye

#Finished