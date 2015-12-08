# VERSION 1.1
# ORIGINAL AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow
# SOURCE: https://github.com/puckel/docker-airflow

FROM liligo/airflow-base
MAINTAINER tromika

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
# Work around initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No

ENV VERSION 0.25.0
ENV PKG_RELEASE 0.2.70


USER root

RUN apt-get -y update
RUN apt-get install -y --force-yes software-properties-common python-software-properties
RUN apt-add-repository -y ppa:webupd8team/java
RUN apt-get -y update
RUN /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install oracle-java7-installer oracle-java7-set-default

RUN apt-get -y install curl

WORKDIR /tmp
RUN \
  curl -s -O https://downloads.mesosphere.io/master/ubuntu/14.04/mesos_${VERSION}-${PKG_RELEASE}.ubuntu1404_amd64.deb && \
  dpkg --unpack mesos_${VERSION}-${PKG_RELEASE}.ubuntu1404_amd64.deb && \
  apt-get install -f -y && \
  rm mesos_${VERSION}-${PKG_RELEASE}.ubuntu1404_amd64.deb && \
  apt-get clean


RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.5.1-bin-hadoop2.6.tgz  | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.5.1-bin-hadoop2.6 spark

RUN curl -s http://www.eu.apache.org/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz  | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s hadoop-2.7.1 hadoop


ENV SPARK_HOME /usr/local/spark
ENV MESOS_NATIVE_LIBRARY /usr/lib/libmesos.so
ENV PYTHONPATH $SPARK_HOME/python/:$PYTHONPATH
ENV PYTHONPATH $SPARK_HOME/python/lib/py4j-0.8.2.1-src.zip:$PYTHONPATH



USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["./entrypoint.sh"]
