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

### Create jar of the job

//TODO

Open project hadoop-wordcout-example and replace all the ips for the master ip on class ``com.gustavonalle.Main```
Deploy jar by running 



``` ./deploy.sh <master ip> ```


### Run the hadoop job

``` 
ssh root@<master ip>
cd /home/hadoop
./run_hadoop_job.sh hadoop-sample-1.0-SNAPSHOT-jar-with-dependencies.jar
```

### Checking output

Output will be in the cache 'map-reduce-out'
Project infinispan-hadoop-integration has a class to dump the cache:

``` org.infinispan.hadoopintegration.util.ControllerCache --host <any docker host> --cachename map-reduce-out --dump ```
