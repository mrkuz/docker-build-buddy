#!/bin/sh -e
if [ "${JAVA_URANDOM:-true}" = "true" ]; then
    JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom $JAVA_OPTS"
fi
if [ "$JAVA_DIAGNOSTICS" = "true" ]; then
    JAVA_OPTS="-XX:+UnlockDiagnosticVMOptions -XX:+PrintFlagsFinal -Xlog:gc $JAVA_OPTS"
fi
if [ "$JAVA_DEBUG" = "true" ]; then
    JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:${JAVA_DEBUG_PORT:-9999} $JAVA_OPTS"
fi

JAVA_OPTS="-XX:+ExitOnOutOfMemoryError $JAVA_OPTS"

echo exec java -cp "libs/*:classes" $JAVA_OPTS $MAIN_CLASS "$@"
exec java -cp "libs/*:classes" $JAVA_OPTS $MAIN_CLASS "$@"
