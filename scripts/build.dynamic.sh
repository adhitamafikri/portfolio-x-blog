#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Builds a Hugo site hosted on a Cloudflare Worker.
#
# The Cloudflare Worker automatically installs Node.js dependencies.
#------------------------------------------------------------------------------

main() {
  DART_SASS_VERSION=1.93.2
  GO_VERSION=1.25.3
  HUGO_VERSION=0.152.2
  NODE_VERSION=22.20.0

  export TZ=Europe/Oslo

  # Detect architecture
  ARCH=$(uname -m)
  echo "Detected architecture: ${ARCH}"

  # Map architecture to package-specific identifiers
  case "${ARCH}" in
    x86_64|amd64)
      DART_SASS_ARCH="x64"
      GO_ARCH="amd64"
      HUGO_ARCH="amd64"
      NODE_ARCH="x64"
      ;;
    aarch64|arm64)
      DART_SASS_ARCH="arm64"
      GO_ARCH="arm64"
      HUGO_ARCH="arm64"
      NODE_ARCH="arm64"
      ;;
    *)
      echo "Unsupported architecture: ${ARCH}"
      exit 1
      ;;
  esac

  # Install Dart Sass
  echo "Installing Dart Sass ${DART_SASS_VERSION} for ${ARCH}..."
  curl -sLJO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-${DART_SASS_ARCH}.tar.gz"
  tar -C "${HOME}/.local" -xf "dart-sass-${DART_SASS_VERSION}-linux-${DART_SASS_ARCH}.tar.gz"
  rm "dart-sass-${DART_SASS_VERSION}-linux-${DART_SASS_ARCH}.tar.gz"
  export PATH="${HOME}/.local/dart-sass:${PATH}"

  # Install Go
  echo "Installing Go ${GO_VERSION} for ${ARCH}..."
  curl -sLJO "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  tar -C "${HOME}/.local" -xf "go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  rm "go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  export PATH="${HOME}/.local/go/bin:${PATH}"

  # Install Hugo
  echo "Installing Hugo ${HUGO_VERSION} for ${ARCH}..."
  curl -sLJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${HUGO_ARCH}.tar.gz"
  mkdir -p "${HOME}/.local/hugo"
  tar -C "${HOME}/.local/hugo" -xf "hugo_extended_${HUGO_VERSION}_linux-${HUGO_ARCH}.tar.gz"
  rm "hugo_extended_${HUGO_VERSION}_linux-${HUGO_ARCH}.tar.gz"
  export PATH="${HOME}/.local/hugo:${PATH}"

  # Install Node.js
  echo "Installing Node.js ${NODE_VERSION} for ${ARCH}..."
  curl -sLJO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"
  tar -C "${HOME}/.local" -xf "node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"
  rm "node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"
  export PATH="${HOME}/.local/node-v${NODE_VERSION}-linux-${NODE_ARCH}/bin:${PATH}"

  # Verify installations
  echo "Verifying installations..."
  echo Dart Sass: "$(sass --version)"
  echo Go: "$(go version)"
  echo Hugo: "$(hugo version)"
  echo Node.js: "$(node --version)"

  # Configure Git
  echo "Configuring Git..."
  git config core.quotepath false
  if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
    git fetch --unshallow
  fi

  # Build the site
  echo "Building the site..."
  hugo --gc --minify

}

set -euo pipefail
main "$@"
