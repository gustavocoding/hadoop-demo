package demo


import java.io.File
import java.nio.file._
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.io.{IntWritable, LongWritable, Text}
import org.apache.hadoop.mapred.JobConf
import org.apache.spark.SparkContext._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}
import org.infinispan.client.hotrod.configuration.ConfigurationBuilder
import org.infinispan.client.hotrod.{RemoteCache, RemoteCacheManager}
import org.infinispan.hadoopintegration.mapreduce.input.InfinispanInputFormat
import org.infinispan.hadoopintegration.mapreduce.output.InfinispanOutputFormat
import org.infinispan.hadoopintegration.sample.{InputConverter, OutputConverter}

import scala.io.Source
import scala.util.Random

object MainDemo extends App with java.io.Serializable {

  lazy val words = Source.fromFile(new File("/usr/share/dict/words")).getLines().toList
  lazy val r = new Random(words.size)

  def mapReduce(rdd: RDD[(LongWritable, Text)]) = {
    rdd.map {
      case (k, v) => v.toString
    }.flatMap(_.split(" ")).map((_, 1)).reduceByKey(_ + _)
  }
  
  def echoMR(): Unit = {
    println(
      """
        rdd.map {
              case (k, v) => v.toString
            }.flatMap(_.split(" ")).map((_, 1)).reduceByKey(_ + _)
      """.stripMargin)
    
  }
  
  def print(rdd: RDD[(String,Int)]): Unit = rdd.toArray().foreach(line => println(line))

  def getRDD(master: String) = {
    val jobConf = jobConfig(master)
    val sc = sparkContext(master)
    sc.hadoopRDD(jobConf, classOf[InfinispanInputFormat[LongWritable, Text]], classOf[LongWritable], classOf[Text], 1)
  }


  def getCache(host: String): RemoteCache[Integer, String] = {
    val rcm = new RemoteCacheManager(new ConfigurationBuilder().addServer().host(host).port(11222).build())
    rcm.getCache[Integer, String]("map-reduce-in")
  }

  def randomPhrase: String = (0 to r.nextInt(10)).map(i => words(r.nextInt(words.size))).mkString(" ")

  def populateCache(c: RemoteCache[Integer, String], n: Int): Unit = (0 to n).foreach(c.put(n, randomPhrase))

  def sparkContext(master: String) = {
    val conf = new SparkConf()
      .setJars(
        List(
          SparkContext.jarOfClass(classOf[InputConverter]).get,
          Paths.get("target/scala-2.10/spark-infinispan-demo_2.10-1.0-SNAPSHOT.jar").toAbsolutePath.toString
        )
      )
      .setMaster(s"spark://$master:7077")
      .setAppName("fosdem")
    new SparkContext(conf)
  }


  def jobConfig(master: String) = {
    val configuration = new Configuration()
    configuration.set("mapreduce.ispn.inputsplit.remote.cache.host", master)
    configuration.set("mapreduce.ispn.input.remote.cache.host", master)
    configuration.set("mapreduce.ispn.output.remote.cache.host", master)
    configuration.set("mapreduce.ispn.input.cache.name", "map-reduce-in")
    configuration.set("mapreduce.ispn.output.cache.name", "map-reduce-out")
    configuration.set("mapreduce.ispn.input.converter", classOf[InputConverter].getCanonicalName())
    configuration.set("mapreduce.ispn.output.converter", classOf[OutputConverter].getCanonicalName())
    val jobConf = new JobConf(configuration)
    jobConf.setOutputKeyClass(classOf[Text])
    jobConf.setOutputValueClass(classOf[IntWritable])
    jobConf.setInputFormat(classOf[InfinispanInputFormat[LongWritable, Text]])
    jobConf.setOutputFormat(classOf[InfinispanOutputFormat[Text, LongWritable]])
    jobConf
  }

  override def main(args: Array[String]) {
    val master = "172.17.0.25"
    val cache = getCache(master)
    cache.clear()
    cache.put(1, "word1 word2 word3")
    cache.put(2, "word1 word2")
    cache.put(3, "word1")
    val rdd = getRDD(master)

    println(rdd.count())
    val mr = mapReduce(rdd)

    print(mr)

  }

}
