FROM golang:1 AS build
WORKDIR /go/src
COPY ["go.mod", "go.sum", "./"]
RUN go mod download
COPY ["main.go", "./"]
RUN CGO_ENABLED=0 go build

FROM alpine:latest
RUN apk add -U --no-cache ca-certificates
COPY --from=build /go/src/pg-test /pg-test
ENTRYPOINT ["/pg-test"]
