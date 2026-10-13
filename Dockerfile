FROM ghcr.io/openclaw/openclaw:latest




CMD ["node", "/app/openclaw.mjs", "gateway", "--allow-unconfigured"]



