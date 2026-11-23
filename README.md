# microservices-proto

Protocol Buffer contracts for the microservices in `github.com/nblok/microservices`,
plus the generated Go code for each service.

```
<service>/<service>.proto   # source of truth
golang/<service>/           # generated code, its own Go module
```

## Generating

Requires `protoc`, `protoc-gen-go`, and `protoc-gen-go-grpc` on your `PATH`.

```sh
./generate.sh          # all services
./generate.sh order    # one service
```

The GitHub Actions workflow in `.github/workflows/generate.yml` does the same on
every push to `main` that touches a `.proto` file and commits the output.

## Releasing a version

Each generated module is versioned with a path-prefixed tag, which is what Go
expects for a module living in a subdirectory:

```sh
git tag golang/order/v0.1.0
git push origin golang/order/v0.1.0
```

(or run the workflow manually with `service=order`, `version=v0.1.0`).

## Consuming

```sh
go get github.com/nblok/microservices-proto/golang/order@v0.1.0
```

For local development without pushing/tagging, add a `replace` to the
consumer's `go.mod`:

```
replace github.com/nblok/microservices-proto/golang/order => ../../microservices-proto/golang/order
```
