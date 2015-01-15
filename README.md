# Infinispan-hadoop-demo


Scripts to demonstrate Infinispan Hadoop Integration inside Docker

### Requirements

* Linux
* Docker service started
* Maven
* sshpass (yum install sshpass)
* ruby

### Obtain projects and build custom infinispan branch


```
mkdir demo && cd demo
git clone https://github.com/gustavonalle/infinispan.git
git clone https://github.com/gustavonalle/hadoop-demo.git
git clone https://github.com/gustavonalle/infinispan-hadoop-integration.git
git clone https://github.com/gustavonalle/hadoop-wordcount-example.git

cd infinispan && git checkout hadoop-fork
mvn clean install -DskipTests=true -s maven-settings.xml

cd ../infinispan-hadoop-integration
mvn clean install

cd ..

```

### Generate sample file

Run script passing the number of lines of the input file (keep it less than 1 million)

```
cd hadoop-demo
./generate-file.sh 100000
```

### Build cluster

Run script to create the cluster passing the number of nodes. Must be root if docker requires it:

```./cluster.sh 3``` 

Each node will be a hadoop slave plus an infinispan server node

After the cluster is created, take note of the master IP

### Populate cache

Open project infinispan-hadoop-integration in the IDE and run main class ```org.infinispan.hadoopintegration.util.WorldCounterPopulator``` to populate the cache with the generated file. The following parameter should be passed

``` --host <master ip> --file ../hadoop-demo/file.txt --cachename map-reduce-in ```

### Run the hadoop job

To run the job that reads and writes from/to infinispan

``` 
ssh root@<master ip>
cd /home/hadoop
./run_hadoop_infinispan.sh <master ip>
```

To run the same job that reads and writes from/to hdfs

```
ssh root@<master ip>
cd /home/hadoop
./copy-to-hdfs.sh
./run_hadoop.sh
```

### Checking output

Output will be in the cache 'map-reduce-out'
Project infinispan-hadoop-integration has a class to dump the cache:

``` org.infinispan.hadoopintegration.util.ControllerCache --host <any docker host> --cachename map-reduce-out --dump ```

### Going further

The existence of an specific InputFormat allows for infinispan to become a citizen of the Hadoop ecosystem. Particularly,
it can be used as a data source for Apache Spark.

In order to run the same map reduce job, but as a Scala script through spark:

Unzip the spark distribution

Run

``` spark-1.1.0-bin-hadoop1/bin/spark-shell --master spark://<master ip>:7077 --jars path/to/hadoop-sample-1.0-SNAPSHOT-jar-with-dependencies.jar ```

The following scala script will set a ```JobConf``` and run a count on the infinispan data:

```
val host = "172.17.0.56"
import org.apache.hadoop.mapred.JobConf
import org.apache.hadoop.conf.Configuration
import com.gustavonalle.hadoop._
import org.infinispan.hadoopintegration.mapreduce.input._
import org.infinispan.hadoopintegration.mapreduce.output._
import org.apache.hadoop.io._

val configuration = new Configuration()
configuration.set("mapreduce.ispn.inputsplit.remote.cache.host", host)
configuration.set("mapreduce.ispn.input.remote.cache.host", host);
configuration.set("mapreduce.ispn.output.remote.cache.host", host);
configuration.set("mapreduce.ispn.input.cache.name", "map-reduce-in");
configuration.set("mapreduce.ispn.output.cache.name", "map-reduce-out");
configuration.set("mapreduce.ispn.input.converter", classOf[InputConverter].getCanonicalName())
configuration.set("mapreduce.ispn.output.converter", classOf[OutputConverter].getCanonicalName())
val jobConf = new JobConf(configuration)
jobConf.setOutputKeyClass(classOf[Text])
jobConf.setOutputValueClass(classOf[IntWritable])
jobConf.setMapperClass(classOf[MapClass]);
jobConf.setReducerClass(classOf[ReduceClass]);
jobConf.setInputFormat(classOf[InfinispanInputFormat[LongWritable,Text]]);
jobConf.setOutputFormat(classOf[InfinispanOutputFormat[Text,LongWritable]]);
val file = sc.hadoopRDD(jobConf,classOf[InfinispanInputFormat[LongWritable,Text]],classOf[LongWritable],classOf[Text],1)

```

To run a map reduce job without infinispan, on top of HDFS:

```
val file = sc.textFile("hdfs://172.17.0.56:9000/redhat/file.txt")
file.count()
val counts = file.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _).take(2)
```






