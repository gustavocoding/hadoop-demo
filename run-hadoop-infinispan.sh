HADOOP_USER=hadoop
echo "Running hadoop job..."
su $HADOOP_USER -s /bin/sh -c "hadoop jar hadoop-sample-1.0-SNAPSHOT-jar-with-dependencies.jar com.gustavonalle.hadoop.Main $1"
echo "Finished hadoop job"
