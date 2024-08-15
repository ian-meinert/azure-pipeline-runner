FROM registry.access.redhat.com/ubi9/ubi-minimal:9.4-1134


ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

ENV AZURE_RUNNER_AGENT_URL=https://vstsagentpackage.azureedge.net/agent/2.217.2/vsts-agent-linux-x64-2.217.2.tar.gz

RUN microdnf update -y && \
    microdnf upgrade -y && \
    microdnf install -y git jq libicu tar wget vim

WORKDIR /azp/

COPY ./start.sh ./
## temp fix to bypass security context for openshift
RUN chmod -Rf 777 /azp

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent
RUN chown -R agent:root /azp /home/agent

USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

RUN wget --no-check-certificate $AZURE_RUNNER_AGENT_URL && \
    tar -xzf *gz


ENTRYPOINT [ "./start.sh" ]
