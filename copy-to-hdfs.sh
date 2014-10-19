HADOOP_USER=hadoop
HDFS_FOLDER=/redhat
OUTPUT=/result
echo "Deleting data"
su $HADOOP_USER -s /bin/sh -c "hadoop fs -rmr $HDFS_FOLDER/*"
su $HADOOP_USER -s /bin/sh -c "hadoop fs -rmr $OUTPUT"
echo "Creating folders"
su $HADOOP_USER -s /bin/sh -c "hadoop fs -mkdir $HDFS_FOLDER"
echo "Copying data to HDFS"
su $HADOOP_USER -s /bin/sh -c "hadoop fs -copyFromLocal /home/hadoop/*.txt $HDFS_FOLDER"
