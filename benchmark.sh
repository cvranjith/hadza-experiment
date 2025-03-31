#!/bin/bash

set -e

# === Configuration ===
export CATALINA_HOME=${PWD}/tomcat/apache-tomcat-11.0.5
export CATALINA_BASE=${CATALINA_HOME}
export PATH=$PATH:${CATALINA_HOME}/bin

# Recommended fixed heap and NMT for memory experiment
export CATALINA_OPTS="-Xms256m -Xmx256m -verbose:class -XX:NativeMemoryTracking=summary"

MODE=$1  # included | provided

if [[ "$MODE" != "included" && "$MODE" != "provided" ]]; then
  echo "Usage: $0 [included|provided]"
  exit 1
fi

APP1_SRC="${PWD}/${MODE}/app1/target/app1.war"
APP2_SRC="${PWD}/${MODE}/app2/target/app2.war"

echo "💡 Deploying WARs from: ${MODE}"
echo "app1 source: $APP1_SRC"
echo "app2 source: $APP2_SRC"

# === Clean old deployments ===
rm -f ${CATALINA_HOME}/webapps/app1*.war
rm -rf ${CATALINA_HOME}/webapps/app1*

rm -f ${CATALINA_HOME}/webapps/app2*.war
rm -rf ${CATALINA_HOME}/webapps/app2*

# === Copy new WARs ===
cp ${APP1_SRC} ${CATALINA_HOME}/webapps/app1.war
cp ${APP2_SRC} ${CATALINA_HOME}/webapps/app2.war

# === Check and Stop Tomcat if already running ===
echo "🔄 Checking if Tomcat is already running..."
TOMCAT_PID=$(jps | grep "Main" | awk '{print $1}' || true)

if [ ! -z "$TOMCAT_PID" ]; then
    echo "⚠️ Tomcat is already running (PID: $TOMCAT_PID) — stopping it first."
    ${CATALINA_HOME}/bin/shutdown.sh 2>/dev/null
    sleep 5
else
    echo "✅ Tomcat is not running."
fi

# === Clean logs AFTER stopping ===
rm -f ${CATALINA_HOME}/logs/*

# === Use gdate or date ===
if command -v gdate > /dev/null; then
    DATE_CMD="gdate"
else
    DATE_CMD="date"
fi

# === Start Tomcat and time it ===
echo "🚀 Starting Tomcat..."
start_time=$($DATE_CMD +%s%3N)

${CATALINA_HOME}/bin/startup.sh

# Wait for server to start
echo "⏳ Waiting for server startup..."
timeout=60
elapsed=0
while ! grep -q "Server startup in" ${CATALINA_HOME}/logs/catalina.out && [[ $elapsed -lt $timeout ]]; do
  sleep 1
  elapsed=$((elapsed+1))
done

end_time=$($DATE_CMD +%s%3N)
startup_time=$((end_time - start_time))

# === Simple counts ===
source_count=$(grep -c "source:" ${CATALINA_HOME}/logs/catalina.out)
objects_count=$(grep -c "objects" ${CATALINA_HOME}/logs/catalina.out)

# === Final Report ===
echo "--------------------------------------------"
echo "📊 Benchmark Summary for mode: $MODE"
echo "Startup Time      : ${startup_time} ms"
echo "Total Class Loads : ${source_count}"
echo "Distinct Classes  : ${objects_count}"
echo "--------------------------------------------"

