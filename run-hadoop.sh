HADOOP_USER=hadoop
HDFS_FOLDER=/redhat
OUTPUT=/result
JOB=${1:-job.jar}
echo "Running hadoop job..."
su $HADOOP_USER -s /bin/sh -c "hadoop jar $JOB com.gustavonalle.hadoop.Main $HDFS_FOLDER $OUTPUT"
echo "Finished hadoop job"
