FROM sequenceiq/hadoop-docker:2.6.0
MAINTAINER SequenceIQ

#support for Hadoop 2.6.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.0-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.0-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.6.0-bin-hadoop2.6/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin
# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

#install R
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install R


#install wget
RUN yum -y install wget
RUN rpm -e cracklib-dicts --nodeps && yum install cracklib-dicts -

#install R-studio
RUN yum install -y openssl098e 
RUN wget https://download2.rstudio.org/rstudio-server-rhel-0.99.896-x86_64.rpm
RUN yum install -y --nogpgcheck rstudio-server-rhel-0.99.896-x86_64.rpm

RUN groupadd rstudio
RUN useradd -g rstudio rstudio
RUN echo rstudio | passwd --stdin rstudio
EXPOSE 8787
CMD /usr/lib/rstudio-server/bin/rserver --server-daemonize 0


#ENTRYPOINT ["/etc/bootstrap.sh"]
