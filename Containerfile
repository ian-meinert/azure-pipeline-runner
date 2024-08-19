FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

####
ENV FQDN_OF_AZURE_HOST=azure.microsoft.com


ENV TARGETARCH="linux-x64"
ENV AGENT_VERSION="3.220.0"
ENV AZURE_RUNNER_AGENT_URL=https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-$TARGETARCH-$AGENT_VERSION.tar.gz
####

RUN microdnf update -y && \
    microdnf upgrade -y && \
    microdnf install -y git jq libicu tar wget openssl-devel

## Add cert to OS for trust
RUN cd /tmp && \
    openssl s_client -showcerts -connect $FQDN_OF_AZURE_HOST:443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $FQDN_OF_AZURE_HOST.pem && \
    cp $FQDN_OF_AZURE_HOST.pem /etc/pki/ca-trust/source/anchors/ && \
    update-ca-trust force-enable && \
    update-ca-trust

## Azure Runner setup
WORKDIR /azp/

COPY ./start.sh ./

RUN wget --no-check-certificate $AZURE_RUNNER_AGENT_URL && \
    tar -xzf *gz

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent && \
## temp fix to bypass security context for openshift
   chmod -Rf 775 /azp && \
   chown -R agent:root /azp /home/agent

USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "./start.sh" ]
