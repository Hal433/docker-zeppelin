# Docker file to build docker image from Zeppelin binary distribution.
#
# Starting the container:
#
# docker run --rm -p 9090:9090 hal433/docker-zeppelin
#
# Debugging:
#
# docker run --rm -it --entrypoint=bash hal433/docker-zeppelin
#

FROM hal433/ds-spark-base

# Configure versions and other settings.
ENV MAVEN_VERSION            3.3.9
ENV ZEPPELIN_VERSION         0.7.0
ENV ZEPPELIN_HOME            /opt/zeppelin
ENV ZEPPELIN_CONF_DIR        $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR    $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_PORT            9090
ENV SCALA_BINARY_VERSION     2.10
ENV SCALA_VERSION            $SCALA_BINARY_VERSION.4

# Maven
ENV MAVEN_DL_URL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
ENV MAVEN_HOME /opt/apache-maven-$MAVEN_VERSION
ENV PATH $PATH:$MAVEN_HOME/bin
RUN curl -sL --retry 3 "$MAVEN_DL_URL"  \
  | gunzip \
  | tar x -C /opt/ && \
  ln -s $MAVEN_HOME /opt/maven

# Scala
# FIXME: Remove downloaded file.
ENV SCALA_DL_URL http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.tgz
RUN curl -sL -k --retry 3 "$SCALA_DL_URL" \
    | gunzip \
    | tar x -C /opt/
ENV SCALA_HOME /opt/scala-$SCALA_VERSION
ENV PATH $SCALA_HOME/bin:$PATH

# RScala
# FIXME: Hard-coded RScala version.
RUN curl -k https://cran.r-project.org/src/contrib/Archive/rscala/rscala_1.0.6.tar.gz -o /opt/rscala_1.0.6.tar.gz && \
    R CMD INSTALL /opt/rscala_1.0.6.tar.gz

# Apache Zeppelin.
ENV ZEPPELIN zeppelin-${ZEPPELIN_VERSION}
ENV PATH $ZEPPELIN_HOME/bin:$PATH
ENV ZEPPELIN_DL_URL http://www-eu.apache.org/dist/zeppelin/${ZEPPELIN}/${ZEPPELIN}-bin-all.tgz
RUN set -x \
    && curl -kfSL "$ZEPPELIN_DL_URL" -o /tmp/zeppelin.tar.gz \
    && tar -xvf /tmp/zeppelin.tar.gz -C /opt/ \
    && rm /tmp/zeppelin.tar.gz*

COPY files/zeppelin-entrypoint.sh /entrypoints/zeppelin-entrypoint.sh
COPY files/inject_interpreter_cfg.py /entrypoints/inject_interpreter_cfg.py
COPY files/inject_zeppelin_cfg.sh /entrypoints/inject_zeppelin_cfg.sh
COPY files/service_wait.sh /entrypoints/service_wait.sh

RUN mv /opt/${ZEPPELIN}-bin-all $ZEPPELIN_HOME && \
    mkdir $ZEPPELIN_HOME/logs && \
    mkdir $ZEPPELIN_HOME/run && \
    chmod a+x /entrypoints/zeppelin-entrypoint.sh && \
    chmod a+x /entrypoints/inject_interpreter_cfg.py && \
    rm -rf /root/.m2 && \
    rm -rf /root/.npm && \
    rm -rf /opt/rscala_1.0.6.tar.gz

WORKDIR /workdir

EXPOSE $ZEPPELIN_PORT

ENTRYPOINT ["/entrypoints/zeppelin-entrypoint.sh"]
