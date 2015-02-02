name := "spark-infinispan-demo"

version := "1.0-SNAPSHOT"

scalaVersion := "2.10.4"

resolvers += Resolver.mavenLocal

retrieveManaged := true

initialCommands in console := """
import demo.MainDemo._
import java.io.File
import org.apache.hadoop.conf._
import org.apache.hadoop.io._
import org.apache.hadoop.mapred.JobConf
import org.infinispan.hadoopintegration.mapreduce.input._
import org.infinispan.hadoopintegration.mapreduce.output._
import org.infinispan.client.hotrod.RemoteCache
import org.infinispan.client.hotrod.configuration._
import org.infinispan.hadoopintegration.sample._
import org.apache.spark.SparkContext._
import org.apache.spark._
"""

libraryDependencies ++= Seq(
  "org.infinispan" % "infinispan-client-hotrod" % "7.1.0.hadoop-SNAPSHOT" ,
  "org.infinispan" % "hadoop-integration-sample" % "7.1.0.hadoop-SNAPSHOT" classifier "jar-with-dependencies" notTransitive,
  "org.apache.spark" %% "spark-core" % "1.1.1"
)
