FROM env-common

ARG pkg
ARG jdk_version
ADD ${pkg} /opt/module/
ENV JAVA_HOME /opt/module/${jdk_version}
ENV PATH $PATH:$JAVA_HOME/bin