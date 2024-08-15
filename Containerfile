FROM registry.access.redhat.com/ubi9/ubi-minimal:9.4-1134
ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

RUN microdnf update -y && \
    microdnf upgrade -y && \
    microdnf install -y curl git jq libicu

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent
RUN chown -R agent:agent /azp /home/agent

USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "./start.sh" ]
