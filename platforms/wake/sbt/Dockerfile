FROM java:8

RUN mkdir /opt/app && \
  mkdir /opt/app/bin && \
  mkdir /opt/src

ENV ENVCONSUL_VERSION 0.6.0
ENV ENVCONSUL_DOWNLOAD_URL https://github.com/hashicorp/envconsul/releases/download/v$ENVCONSUL_VERSION/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
ENV ENVCONSUL_SHA256 d675aa6776e40c5b116dabc625a4ab6d8f6ac1f3b03337f6cad1834fee813aef

ENV SCALA_VERSION 2.11.7
ENV SCALA_DOWNLOAD_URL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz

ENV SBT_VERSION 0.13.8
ENV SBT_DOWNLOAD_URL https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb

ENV PATH /opt/app/bin:/opt/src/scala-$SCALA_VERSION/bin:$PATH

# Install envconsul
RUN curl -L -o /opt/src/envconsul.zip "$ENVCONSUL_DOWNLOAD_URL" \
 && echo "${ENVCONSUL_SHA256}  /opt/src/envconsul.zip" > /opt/src/envconsul.sha256 \
 && sha256sum -c /opt/src/envconsul.sha256 \
 && cd /opt/app/bin \
 && unzip /opt/src/envconsul.zip \
 && chmod +x /opt/app/bin/envconsul \
 && rm /opt/src/envconsul.zip

# Install Scala
RUN cd /opt/src \
 && curl -L -o scala.tgz "$SCALA_DOWNLOAD_URL" \
 && mkdir scala \
 && tar -xf scala.tgz -C scala \
 && rm scala.tgz

# Install sbt
RUN curl -L -o sbt.deb "$SBT_DOWNLOAD_URL" \
 && dpkg -i sbt.deb \
 && rm sbt.deb \
 && apt-get update \
 && apt-get install sbt \
 && sbt version

# Add necessary files to load dependencies
ADD build.sbt .build-env /opt/app/
ADD project/ /opt/app/project/

# update and compile so all depencendies are loaded
RUN cd /opt/app \
 && eval "$(test -e .build-env && cat .build-env)" \
 && sbt update \
 && sbt compile

# Add all the code
ADD . /opt/app/

# forealz compile
RUN cd /opt/app \
 && eval "$(test -e .build-env && cat .build-env)" \
 && sbt assembly

ARG sha
ARG start

RUN echo cd /opt/app > /opt/start \
 && echo envexec $start >> /opt/start \
 && chmod +x /opt/start

RUN echo $sha > /opt/app/sha

CMD /opt/start
