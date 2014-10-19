# Infinispan-hadoop-demo


Scripts to demonstrate Infinispan Hadoop Integration inside Docker

### Requirements

* Linux
* Docker service started
* Maven
* sshpass (yum install sshpass)

### Obtain projects and build custom infinispan branch


```
mkdir demo && cd demo
git clone https://github.com/gustavonalle/infinispan.git
git clone https://github.com/gustavonalle/hadoop-demo.git
git clone https://github.com/pruivo/infinispan-hadoop-integration.git
git clone https://github.com/pruivo/hadoop-wordcount-example.git

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
