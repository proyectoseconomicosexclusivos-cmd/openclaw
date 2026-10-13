FROM ghcr.io/openclaw/openclaw:latest-slim


CMD ["node", "/app/openclaw.mjs", "gateway", "--allow-unconfigured"]

