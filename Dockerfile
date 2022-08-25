# Use static version to avoid version issues
FROM ghcr.io/foundry-rs/foundry:nightly-e4f6b1d6dcab462a6f48b0a9e65f752c9f020338

WORKDIR /app
COPY . .