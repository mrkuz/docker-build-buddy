FROM ubuntu:18.04
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash ca-certificates curl inotify-tools less openssh-server rsync sudo unzip vim zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/protocolbuffers/protobuf/releases/download/v3.9.0/protoc-3.9.0-linux-x86_64.zip -o protoc.zip \
    && unzip protoc.zip -d /usr/local bin/protoc \
    && rm protoc.zip

RUN groupadd -r wheel && echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
RUN useradd -u 1000 -G wheel -s /bin/bash -d /home/user -m user \
    && mkdir /home/user/build \
    && chown -R user:user /home/user

USER user
WORKDIR /home/user/

RUN bash -c 'curl https://get.sdkman.io -o sdkman.sh \
    && chmod u+x sdkman.sh \
    && ./sdkman.sh \
    && rm sdkman.sh \
    && source ~/.sdkman/bin/sdkman-init.sh \
    && sdk install java 12.0.2-zulu \
    && sdk install gradle 5.4.1 \
    && sdk flush archives'

RUN mkdir -p ~/.gradle/caches/

COPY --chown=user:user id_rsa.pub .ssh/authorized_keys
COPY --chown=user:user gradle.properties .gradle/gradle.properties
COPY --chown=user:user spring-boot-devtools.properties .spring-boot-devtools.properties
COPY --chown=user:user start.sh start.sh

EXPOSE 22 8080 9999
ENTRYPOINT [ "/home/user/start.sh" ]
