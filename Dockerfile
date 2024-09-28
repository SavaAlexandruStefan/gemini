FROM golang:alpine AS build

RUN apk add git openssl
RUN go install tildegit.org/solderpunk/molly-brown@latest
RUN openssl req \
      -newkey rsa:4096 \
      -x509 \
      -days 3650 \
      -subj '/CN=localhost' \
      -addext "subjectAltName = DNS:localhost" \
      -nodes \
      -out molly.crt \
      -keyout molly.key

FROM alpine:latest

RUN addgroup --system molly && \
    adduser  --system molly
RUN mkdir /opt/molly && \
    chown molly:molly /opt/molly
COPY --from=build --chown=molly:molly /go/bin/molly-brown /opt/molly/molly-brown
COPY --from=build --chown=molly:molly /go/molly.crt       /opt/molly/molly.crt
COPY --from=build --chown=molly:molly /go/molly.key       /opt/molly/molly.key
COPY --chown=molly:molly ./molly-brown/molly.conf /opt/molly/molly.conf
COPY --chown=molly:molly ./molly-brown/molly.log /opt/molly/molly.log
COPY --chown=molly:molly ./molly-brown/access.log /opt/molly/access.log
COPY --chown=molly:molly ./gemini-content/ /var/gemini/
RUN ln -s /opt/molly/molly.conf /etc/molly.conf
USER molly
ENTRYPOINT ["/opt/molly/molly-brown"]
EXPOSE 1965