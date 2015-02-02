# Infinispan-hadoop-demo


Scripts to demonstrate Infinispan Hadoop Integration inside Docker

### Requirements

* Linux
* Docker service started
* Maven/SBT
* sshpass (yum install sshpass)
* ruby

### Build custom branch 

Build hadoop integration branch:
```
git clone -b ISPN-5191/hadoop-integration --single-branch https://github.com/infinispan/infinispan.git
cd infinispan && mvn clean install -DskipTests=true -s maven-settings.xml
```

Edit cluster.sh and change the variable ```$ISPN_HOME``` to point to the sources folder above 

### Build cluster

Run script to create the cluster passing the number of nodes. Must be root if docker requires it:

```./cluster.sh 3``` 

Each node will be a hadoop slave, infinispan server node and spark worker

After the cluster is created, take note of the master IP

At this point the hadoop cluster admin insterfaces are accessible at:

```
http://<master ip>:50030  (jobtracker)
http://<master ip>:50070  (namenode)
```

and the spark cluster admin at:
 
```
http://<master ip>:8081
```

### Run the hadoop job

To run the job that reads and writes from/to infinispan:

``` 
ssh root@<master ip>
cd /home/hadoop
./run_hadoop_infinispan.sh
```

To run the same job that reads and writes from/to hdfs:

```
ssh root@<master ip>
cd /home/hadoop
./copy-to-hdfs.sh
./run_hadoop.sh
```

### Checking output

Output will be in the cache 'map-reduce-out'
To read the output, run (outside docker):

``` ./dump.sh | more ```


### Run spark 

The existence of an specific InputFormat allows for infinispan to become a citizen of the Hadoop ecosystem. Particularly,
it can be used as a data source for Apache Spark.

In order to run the same map reduce job, but as a Scala script through spark:


```
cd shell
./shell.sh
```

```
scala> val master = <master ip>
scala> val cache = getCache(master)
scala> cache.size
scala> val rdd = getRDD(master)
scala> val mr = mapReduce(rdd)
scala> print(mr)
```

Spark also works on top of pure HDFS. The equivalent of doing a wordcount mapreduce on top of HDFS is:


```
val file = sc.textFile(s"hdfs://$master:9000/redhat/file.txt")
file.count()
val counts = file.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _).take(10)
```

