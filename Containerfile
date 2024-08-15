FROM registry.access.redhat.com/ubi9/ubi-minimal:9.4-1134

ENV FQDN_OF_AZURE_HOST=someDomain.com

ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

ENV AZURE_RUNNER_AGENT_URL=https://vstsagentpackage.azureedge.net/agent/3.220.0/vsts-agent-linux-x64-3.220.0.tar.gz

RUN microdnf update -y && \
    microdnf upgrade -y && \
    microdnf install -y git jq libicu tar wget openssl-devel

## Add cert to OS for trust
RUN cd /tmp && \
    openssl s_client -showcerts -connect $FQDN_OF_AZURE_HOST:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > $FQDN_OF_AZURE_HOST.crt && \
    cp $FQDN_OF_AZURE_HOST.crt /etc/pki/ca-trust/source/anchors/ && \
    update-ca-trust

## Azure Runner setup
WORKDIR /azp/

COPY ./start.sh ./

RUN wget --no-check-certificate $AZURE_RUNNER_AGENT_URL && \
    tar -xzf *gz

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent && \
## temp fix to bypass security context for openshift
   chmod -Rf 777 /azp && \
   chown -R agent:root /azp /home/agent

USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"


ENTRYPOINT [ "./start.sh" ]
