#!/bin/bash

set -o pipefail -e

TEMPLATE="Dockerfile.tpl"

JVM_VERSIONS=( 7 8 9 )
TOMCAT_VERSIONS=( 7.0.92 8.5.35 9.0.13 )

for JVM_VERSION in ${JVM_VERSIONS[@]}; do
  for TOMCAT_VERSION in ${TOMCAT_VERSIONS[@]}; do
    TOMCAT_MAJOR=$(echo $TOMCAT_VERSION | cut -d. -f1)

    JVM_FLAVOUR=oracle-jre-${JVM_VERSION}
    echo -en "Generating Dockerfile for Tomcat ${TOMCAT_VERSION} using Java ${JVM_FLAVOUR}..."
    sed "s|%JVM_FLAVOUR%|$JVM_FLAVOUR|g;s|%TOMCAT_VERSION%|$TOMCAT_VERSION|g;s|%TOMCAT_MAJOR%|$TOMCAT_MAJOR|g" $TEMPLATE > ../tomcat${TOMCAT_MAJOR}/Dockerfile.${JVM_FLAVOUR} && \
      echo "done" || \
      echo "failed"

    JVM_FLAVOUR=oracle-jdk-${JVM_VERSION}
    echo -en "Generating Dockerfile for Tomcat ${TOMCAT_VERSION} using Java ${JVM_FLAVOUR}..."
    sed "s|%JVM_FLAVOUR%|$JVM_FLAVOUR|g;s|%TOMCAT_VERSION%|$TOMCAT_VERSION|g;s|%TOMCAT_MAJOR%|$TOMCAT_MAJOR|g" $TEMPLATE > ../tomcat${TOMCAT_MAJOR}/Dockerfile.${JVM_FLAVOUR} && \
      echo "done" || \
      echo "failed"
  done
done
