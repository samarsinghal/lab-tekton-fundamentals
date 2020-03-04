FROM quay.io/eduk8s/workshop-dashboard:master

ENV TKN_CLI_VERSION=0.8.0
RUN curl -kLs https://github.com/tektoncd/cli/releases/download/v${TKN_CLI_VERSION}/tkn_${TKN_CLI_VERSION}_Linux_x86_64.tar.gz -o /home/eduk8s/tkn.tar.gz && \
tar -xvzf tkn.tar.gz && \
chmod 755 tkn && \
mv tkn /opt/eduk8s/bin

COPY --chown=1001:0 . /home/eduk8s/
