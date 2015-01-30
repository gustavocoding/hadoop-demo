HADOOP_USER=hadoop
HDFS_FOLDER=/redhat
OUTPUT=/result
echo "Running hadoop job..."
su $HADOOP_USER -s /bin/sh -c "hadoop jar $JOB hadoop-integration-sample-jar-with-dependencies.jar org.infinispan.hadoopintegration.sample.HDFSMain $HDFS_FOLDER $OUTPUT"
echo "Finished hadoop job"

