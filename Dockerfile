FROM openjdk:8

ARG user=cjman
ARG group=cjman
ARG uid=1000
ARG gid=1000
ENV CJMAN_HOME /var/cjman

RUN groupadd -g ${gid} ${group} \
    && useradd -d "$CJMAN_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# 使用淘宝镜像安装Node.js
ENV NODE_VERSION 10.13.0
RUN wget https://npm.taobao.org/mirrors/node/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz && \
    tar -C /usr/local --strip-components 1 -xzf node-v${NODE_VERSION}-linux-x64.tar.gz && \
    rm node-v${NODE_VERSION}-linux-x64.tar.gz

# # Global install yarn package manager
RUN apt-get update && apt-get install -y curl apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# # ——————————
# # Installs i386 architecture required for running 32 bit Android tools
# # ——————————
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

# # Setup environment
ENV ANDROID_HOME="/opt/android-sdk-linux"
ENV ANDROID_SDK="${ANDROID_HOME}"
ENV PATH="${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools:${ANDROID_SDK}/tools/bin:${PATH}"
RUN echo "export PATH=${PATH}" > /root/.profile

ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip

RUN curl -L "${ANDROID_SDK_URL}" -o /tmp/android-sdk-linux.zip && \
    unzip /tmp/android-sdk-linux.zip -d /opt/ && \
    chown -R root:root /opt && \
    rm /tmp/android-sdk-linux.zip && \
    mkdir ${ANDROID_HOME} && \
    mv /opt/tools ${ANDROID_HOME}/ && \
    ls ${ANDROID_HOME} && \
    ls ${ANDROID_HOME}/tools && chown -R root:root ${ANDROID_HOME}

# # Install Android SDK components
RUN echo y | sdkmanager "platform-tools" "build-tools;27.0.3" "build-tools;26.0.2" "build-tools;25.0.3" "build-tools;23.0.1"  "platforms;android-27" "platforms;android-26" "platforms;android-25" "platforms;android-23"  "extras;google;m2repository" "extras;android;m2repository" "extras;google;google_play_services"

RUN echo ANDROID_HOME="$ANDROID_HOME" >> /etc/environment

WORKDIR ${CJMAN_HOME}

COPY deploy.sh script/deploy.sh

RUN chomd -R ${user}:${user} script

CMD ["./script/deploy.sh"]
