#!/bin/sh
# ----------------------------------------------------------------------------
# Maven Wrapper startup script for POSIX compliant shells
# ----------------------------------------------------------------------------

set -euf
WRAPPER_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BASE_DIR="$WRAPPER_DIR"
[ -d "$BASE_DIR/.mvn" ] || BASE_DIR="$WRAPPER_DIR/.."
PROPS="$BASE_DIR/.mvn/wrapper/maven-wrapper.properties"
[ -f "$PROPS" ] || { echo "Cannot find $PROPS"; exit 1; }
WRAPPER_JAR="$BASE_DIR/.mvn/wrapper/maven-wrapper.jar"
WRAPPER_VERSION=3.3.2

wrapperUrl=$(grep -E "^wrapperUrl=" "$PROPS" | cut -d'=' -f2- || true)
if [ -z "$wrapperUrl" ]; then
  wrapperUrl="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/$WRAPPER_VERSION/maven-wrapper-$WRAPPER_VERSION.jar"
fi

if [ ! -f "$WRAPPER_JAR" ]; then
  echo "Downloading Maven Wrapper..." >&2
  mkdir -p "$BASE_DIR/.mvn/wrapper"
  curl -fsSL "$wrapperUrl" -o "$WRAPPER_JAR"
fi

exec "${JAVA_HOME:-}/bin/java" -cp "$WRAPPER_JAR" org.apache.maven.wrapper.MavenWrapperMain "$@"

