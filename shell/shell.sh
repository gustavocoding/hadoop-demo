export SBT_OPTS="-Xmx5000m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=2G -Xss2M  -Duser.timezone=GMT"
sbt package
sbt console
