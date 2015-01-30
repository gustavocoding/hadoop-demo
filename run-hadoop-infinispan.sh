HADOOP_USER=hadoop
MASTER_IP=$(/sbin/ifconfig | grep 172 | awk '{print $2}')
echo "Running hadoop job..."
su $HADOOP_USER -s /bin/sh -c "hadoop jar hadoop-integration-sample-jar-with-dependencies.jar org.infinispan.hadoopintegration.sample.Main $MASTER_IP"
echo "Finished hadoop job"
