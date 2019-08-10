#!/bin/bash

sudo /etc/init.d/ssh status || sudo /etc/init.d/ssh start

source "/home/user/.sdkman/bin/sdkman-init.sh"

PROJECT="$1"
MAIN_CLASS="$2"

if [[ -z "$PROJECT" || -z "$MAIN_CLASS" ]]; then
    echo "Usage: $0 PROJECT MAIN_CLASS"
    exit 1
fi

SRC='/home/user/src'
BUILD='/home/user/build'
RUN='/home/user/run'
TRIGGER='/home/user/trigger'
TMP='/home/user/tmp'

[ -d "$SRC" ] || mkdir "$SRC/"
[ -d "$BUILD" ] || mkdir "$BUILD/"
[ -d "$RUN" ] || mkdir "$RUN/"
[ -d "$TRIGGER" ] || mkdir "$TRIGGER/"

function src2BuildLoop() {
    while true; do
        if [[ ! -f "$TRIGGER/buildLoop" ]]; then
            inotifywait -qq -r -e modify,create,delete "$SRC/"
            echo "First run. Waiting 10 seconds..."
            sleep 10
            rsync -i -a --delete "$SRC/" "$BUILD/" --exclude 'build' --exclude 'out' --exclude 'tmp' --exclude '.gradle' --exclude '.git'
            touch "$TRIGGER/buildLoop"
        else
            inotifywait -qq -r -e modify,create,delete -t 1 "$SRC"
            rsync -i -a --delete "$SRC/" "$BUILD/" --exclude 'build' --exclude 'out' --exclude 'tmp' --exclude '.gradle' --exclude '.git'
        fi
    done
}

function buildLoop() {
    while true; do
        if [[ -f "$TRIGGER/buildLoop" ]]; then
            if [[ ! -f "$TRIGGER/build2RunLoop" ]]; then
                gradle -p "$BUILD/" installDist -x test
                touch "$TRIGGER/build2RunLoop"
            else
                gradle -p "$BUILD/" -t jar -x test
            fi
        else
            sleep 1
        fi
    done
}

function build2RunLoop() {
    while true; do
        if [[ -f "$TRIGGER/build2RunLoop" && -d "$BUILD/build/install/$PROJECT/lib/" ]]; then
            if [[ ! -f "$TRIGGER/runLoop" ]]; then
                rsync -i -a --delete "$BUILD/build/install/$PROJECT/lib/" --exclude "$PROJECT-"*.jar "$RUN/lib/"
                rm -rf "$TMP"
                unzip "$BUILD/build/libs/$PROJECT-"*.jar -d "$TMP"
                rsync -i -a --delete "$TMP/" "$RUN/classes/"
                touch "$TRIGGER/runLoop"
            else
                inotifywait -qq -r -e modify,create,delete "$BUILD/build/libs/"
                rm -rf "$TMP"
                unzip "$BUILD/build/libs/$PROJECT-"*.jar -d "$TMP"
                rsync -i -a --delete "$TMP/" "$RUN/classes/"
            fi
        else
            sleep 1
        fi
    done
}

function runLoop() {
    while true; do
        if [[ -f "$TRIGGER/runLoop" && -d "$RUN/classes/" ]]; then
            java $JAVA_OPTS \
                 -XX:+ExitOnOutOfMemoryError \
                 -Djava.security.egd=file:/dev/./urandom \
                 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:${JAVA_DEBUG_PORT:-9999} \
                 -cp $RUN/classes:$RUN/lib/* \
                 $MAIN_CLASS
        else
            sleep 1
        fi
    done
}

runLoop &
build2RunLoop &
buildLoop &
src2BuildLoop
