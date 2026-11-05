# PASHUPATI Backend Dockerfile (Multi-stage build)

FROM rust:1.80-slim as builder

WORKDIR /usr/src/pashupati

RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*

COPY Cargo.toml ./
COPY openapi.yaml ./
COPY migrations ./migrations
COPY src ./src

# Build release binary
RUN cargo build --release

# Production Runtime
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates libssl3 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /usr/src/pashupati/target/release/pashupati-backend /app/pashupati-backend
COPY --from=builder /usr/src/pashupati/migrations /app/migrations

ENV HOST=0.0.0.0
ENV PORT=8080
ENV ENVIRONMENT=production

EXPOSE 8080

CMD ["/app/pashupati-backend"]

