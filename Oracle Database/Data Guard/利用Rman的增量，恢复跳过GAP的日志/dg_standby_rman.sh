rman target / <<EOF
catalog start with '/<rman_bak_dir>/';
yes
shutdown immediate;
startup nomount;
restore standby controlfile from '/<rman_bak_dir>/Ctrl_standby.ctrl';
alter database mount;

run
{
set newname for datafile 358 to '/xxxxxxx.dbf';
set newname for datafile 359 to '/xxxxxxx.dbf';
set newname for datafile 360 to '/xxxxxxx.dbf';
set newname for datafile 361 to '/xxxxxxx.dbf';
set newname for datafile 362 to '/xxxxxxx.dbf';
set newname for datafile 363 to '/xxxxxxx.dbf';
restore datafile 358,359,360,361,362,363;
}

recover database noredo;
EOF
