FROM golang:1.9 AS builder
ENV nomadversion v0.6.3
RUN mkdir -p /go/src/github.com/hashicorp && \
        git clone https://github.com/hashicorp/nomad -b ${nomadversion} /go/src/github.com/hashicorp/nomad && \
        cd /go/src/github.com/hashicorp/nomad && \
        make bootstrap && \
        make pkg/linux_amd64/nomad

FROM debian:stretch
RUN mkdir -p /nomad/data /nomad/config /nomad/bin
COPY server.hcl client.hcl /nomad/config/
COPY --from=builder /go/src/github.com/hashicorp/nomad/pkg/linux_amd64/nomad /nomad/bin/
VOLUME /nomad/data
ENTRYPOINT ["/nomad/bin/nomad"]
CMD ["agent","-config=/nomad/config/client.hcl"]

