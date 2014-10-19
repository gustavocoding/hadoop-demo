#!/bin/bash
set -e

# Number of nodes in the cluster
N=${1:-3}

# Location of the patched infinispan with extra hotrod operations 
ISPN_SERVER_DIST=/home/gfernandes/code/infinispan-hadoop-fork/server/integration/build/target/infinispan-server-7.0.0.hadoop-SNAPSHOT

function run()
{
  echo "$(docker run -i -t -d  gustavonalle/hadoop-base)"
}

function ip()
{
  echo "$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1)" 
}

function exec_cmd()
{
  sshpass -p "root" ssh -o StrictHostKeyChecking=no root@$1 $2 
}

function copy_keys()
{
  exec_cmd $1 "mkdir -p /root/.ssh/ &&  /bin/cp -r /home/hadoop/.ssh/* /root/.ssh/"
}

function replace_hosts()
{
  exec_cmd $1 "sed -i 's/2eec834d0397/$IP_MASTER/g' /opt/hadoop/hadoop-1.1.1/conf/*.xml" 
}

function replace_slave()
{
 exec_cmd $1 "sed -i '/.*slave.*/{n; s/.*/\<value\>$1\<\/value\>/}' /opt/hadoop/hadoop-1.1.1/conf/mapred-site.xml" 
}

function set_master()
{
  exec_cmd $1 "echo '$2' > /opt/hadoop/hadoop-1.1.1/conf/masters"
}

function add_slave()
{
  exec_cmd $1 "echo '$2' >> /opt/hadoop/hadoop-1.1.1/conf/slaves"
}

function remove_slaves() 
{
 exec_cmd $1 "> /opt/hadoop/hadoop-1.1.1/conf/slaves"
}

function copy_file()
{
sshpass -p "root" scp $2 root@$1:$3
}


function setup_server()
{
sshpass -p "root" scp -rp $ISPN_SERVER_DIST root@$1:/root/ispn-server
sshpass -p "root" scp -rp standalone.xml root@$1:/root/ispn-server/standalone/configuration/
sshpass -p "root" ssh -o StrictHostKeyChecking=no root@$1 "nohup /root/ispn-server/bin/standalone.sh -b '$1' >out.txt 2>&1 &"
}

function copy_job() 
{
 copy_file $1 *.jar /home/hadoop
 copy_file $1 *.txt /home/hadoop
 copy_file $1 *.sh /home/hadoop
}

echo "Creating a cluster of $N slaves"

IDMASTER=$(run)
sleep 10 

IP_MASTER=$(ip $IDMASTER)

echo "Master created, ip address is $IP_MASTER"

copy_keys $IP_MASTER
replace_hosts $IP_MASTER
set_master $IP_MASTER $IP_MASTER
remove_slaves $IP_MASTER
setup_server $IP_MASTER
copy_job $IP_MASTER

START=1
for (( c=$START; c<=$N; c++)) 
do
 IDSLAVE=$(run) 
 sleep 10 
 IP_SLAVE=$(ip $IDSLAVE)
 replace_hosts $IP_SLAVE
 replace_slave $IP_SLAVE
 set_master $IP_SLAVE $IP_MASTER
 echo  "Slave $IP_SLAVE configured"
 add_slave $IP_MASTER $IP_SLAVE
 echo "Copying ispn server"
 setup_server $IP_SLAVE
done

echo "Starting process"
exec_cmd $IP_MASTER "/etc/init.d/hadoop-master start"  
exec_cmd $IP_MASTER "/etc/init.d/hadoop-jobtracker start"  

echo  "Cluster started. Master is $IP_MASTER"
