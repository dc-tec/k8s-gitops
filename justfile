#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.

# Default environment
set dotenv-load

env := "tst"

@k8s-context ENV=env:
    kubectl config use-context admin@{{ENV}}-dct-gitops
    talosctl config context {{ENV}}-dct-gitops
    echo "Switched to {{ENV}} environment"


