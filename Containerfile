FROM quay.io/prucek/go-build-root:latest
COPY ../ /source/
WORKDIR /source
RUN go build ./cmd/sort
