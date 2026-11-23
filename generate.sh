#!/usr/bin/env bash
# Generate Go code for one or more services.
#
#   ./generate.sh            # all services (every top-level dir with .proto files)
#   ./generate.sh order      # just the order service
#
# Output goes to golang/<service>/, which is its own Go module:
#   github.com/nblok/microservices-proto/golang/<service>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
MODULE_PREFIX="github.com/nblok/microservices-proto/golang"
cd "$ROOT"

if [[ $# -gt 0 ]]; then
  services=("$@")
else
  services=()
  for dir in */; do
    dir="${dir%/}"
    [[ "$dir" == "golang" ]] && continue
    compgen -G "$dir/*.proto" >/dev/null && services+=("$dir")
  done
fi

for service in "${services[@]}"; do
  echo "==> Generating $service"
  out="golang/$service"
  mkdir -p "$out"
  rm -f "$out"/*.pb.go

  protoc \
    --proto_path="$ROOT" \
    --go_out="$out" --go_opt=paths=source_relative \
    --go-grpc_out="$out" --go-grpc_opt=paths=source_relative \
    "$service"/*.proto

  # protoc mirrors the source dir (golang/order/order/*.pb.go); flatten it.
  mv "$out/$service"/*.pb.go "$out"/
  rmdir "$out/$service"

  (
    cd "$out"
    [[ -f go.mod ]] || go mod init "$MODULE_PREFIX/$service"
    go mod tidy
  )
done
