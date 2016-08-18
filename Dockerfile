
# monetdb
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
MAINTAINER George Tavares <tavares.george@gmail.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
ENV MONETDB_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
#LABEL io.k8s.description="Platform for building xyz" \
#      io.k8s.display-name="builder x.y.z" \
#      io.openshift.expose-services="8080:http" \
#      io.openshift.tags="builder,x.y.z,etc."

# TODO: Install required packages here:
RUN yum install -y wget nano

#RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
#RUN rpm -ivh epel-release-7-8.noarch.rpm
RUN yum install -y http://dev.monetdb.org/downloads/epel/MonetDB-release-epel-1.1-1.monetdb.noarch.rpm
RUN rpm --import http://dev.monetdb.org/downloads/MonetDB-GPG-KEY
RUN yum install -y MonetDB-SQL-server5-hugeint
RUN yum install -y MonetDB-client
RUN yum install -y supervisor


RUN yum clean all -y

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

COPY scripts/set-monetdb-password.sh ${HOME}/set-monetdb-password.sh
RUN chmod +x ${HOME}/set-monetdb-password.sh

COPY scripts/init-db.sh ${HOME}/init-db.sh
RUN chmod +x ${HOME}/init-db.sh

COPY configs/.monetdb ${HOME}/.monetdb


COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf



# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./.s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 ${HOME}
RUN chown -R 1001:1001 /var/monetdb5

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 50000

# TODO: Set the default CMD for the image
# CMD ["usage"]

RUN sh ${HOME}/init-db.sh


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

