# Opt-in plugin dependencies and supported runtime builds (space- or comma-separated ids).
# Manifest ids and existing source-directory names are accepted.
# Example: docker build --build-arg OPENCLAW_EXTENSIONS="diagnostics-otel,matrix" .
#
# Multi-stage build produces a minimal runtime image without build tools,
# source code, or Bun. Works with Docker, Buildx, and Podman.
# The dependency manifest stages extract only package.json files, so the main
# build layer is not invalidated by unrelated source changes.
#
# Build stages use full bookworm; the runtime image is always bookworm-slim.
ARG OPENCLAW_EXTENSIONS=""
ARG OPENCLAW_BUNDLED_PLUGIN_DIR=extensions
ARG OPENCLAW_DOCKER_BUILD_NODE_OPTIONS="--max-old-space-size=8192"
ARG OPENCLAW_DOCKER_BUILD_TSDOWN_MAX_OLD_SPACE_MB="2048"
ARG OPENCLAW_DOCKER_BUILD_SKIP_DTS=1
ARG OPENCLAW_NODE_BOOKWORM_IMAGE="docker.io/library/node:24-bookworm@sha256:64af3819f9275802414d7cdc38c27e9d82bd564dec4d4da87d008255d36c63b4"
ARG OPENCLAW_NODE_BOOKWORM_SLIM_IMAGE="docker.io/library/node:24-bookworm-slim@sha256:0e0ff40c39bc087845bfb27465a0df4ea419520094bc35842ff83dd8cbe6f9b6"
ARG OPENCLAW_NODE_BOOKWORM_SLIM_DIGEST="sha256:0e0ff40c39bc087845bfb27465a0df4ea419520094bc35842ff83dd8cbe6f9b6"
# Keep in sync with .github/actions/setup-node-env/action.yml bun-version.
# To update: docker buildx imagetools inspect docker.io/oven/bun:<version> and use the manifest-list digest.
ARG OPENCLAW_BUN_IMAGE="docker.io/oven/bun:1.4.2@sha256:9114c058aeae42162ee16dd5084b95fe9473970bb6bcb5b232ab1630f0546895"


# Base images are pinned to SHA256 digests for reproducible builds.
# Dependabot refreshes these blessed digests; release builds consume the
# reviewed base snapshot instead of mutating distro state on every build.
# To update, run: docker buildx imagetools inspect docker.io/library/node:24-bookworm and
# docker.io/library/node:24-bookworm-slim (or podman) and replace the digests below with the
# current multi-arch manifest list entries.


FROM ${OPENCLAW_NODE_BOOKWORM_IMAGE} AS workspace-deps
ARG OPENCLAW_EXTENSIONS
ARG OPENCLAW_BUNDLED_PLUGIN_DIR
# Frozen installs validate every lockfile importer's manifest, including unselected plugins.
# Stage all workspace manifests, then filter dependency installation separately.
# Manifest-only bundled plugins remain valid selections but need no workspace metadata.
# Use COPY because build-context bind mounts are unreliable across supported
