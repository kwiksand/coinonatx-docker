FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m coinonatx

#ENV DAEMON_RELEASE="COINONATX-v0.12.1.5"
ENV DAEMON_RELEASE="master"
ENV COINONATX_DATA=/home/coinonatx/.CoinonatX.conf

USER coinonatx

RUN cd /home/coinonatx && \
    mkdir /home/coinonatx/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/coinonat/CoinonatX.git CoinonatXd && \
    cd src/ && \

#USER root
#RUN cd /home/coinonatx/CoinonatXd/src && \
    chmod 755 leveldb/build_detect_platform && \
    make -f makefile.unix && \ 
    cd /home/coinonatx/CoinonatXd && \
    strip src/coinonatxd && \
    mv src/coinonatxd /home/coinonatx/bin && \
    rm -rf /home/coinonatx/coinonatxd
    
EXPOSE 44578 44678

#VOLUME ["/home/coinonatx/.CoinonatX"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    echo "\n# Some aliases to make the coinonatx clients/tools easier to access\nalias coinonatxd='/usr/bin/coinonatxd -conf=/home/coinonatx/.CoinonatX/CoinonatX.conf'\nalias CoinonatXd='/usr/bin/CoinonatXd -conf=/home/coinonatx/.CoinonatX/CoinonatX.conf'\n\n[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc && \
    echo "CoinonatX (XCXT) Cryptocoin Daemon\n\nUsage:\n coinonatxd help - List help options\n coinonatxd listtransactions - List Transactions\n\n" > /etc/motd && \
    chmod 755 /home/coinonatx/bin/coinonatxd && \
    mv /home/coinonatx/bin/coinonatxd /usr/bin/coinonatxd && \
    ln -s /usr/bin/coinonatxd /usr/bin/CoinonatXd

ENTRYPOINT ["/entrypoint.sh"]

CMD ["coinonatxd"]
