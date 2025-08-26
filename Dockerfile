# Use a stable Rust image for multi-platform compatibility
FROM rust:1.78-bullseye AS builder

# Install required dependencies for AMD64 and ARM64
RUN apt-get update && \
    apt-get install -y \
        cmake \
        build-essential \
        pkg-config \
        libssl-dev \
        libclang-dev \
        && rm -rf /var/lib/apt/lists/*

# Set environment variable for libclang
ENV LIBCLANG_PATH=/usr/lib/llvm-11/lib

# Set working directory in the container
WORKDIR /usr/src/electrs

# Copy all source code to the container
COPY . .

# Build electrs without restricting to liquid feature
RUN cargo install --locked --path . --root /usr/local

# Use a slim runtime image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y \
        libssl1.1 \
        && rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /usr/local/bin/electrs /usr/local/bin/electrs

# Expose ports: 3000 (HTTP API), 4224 (stats), 50001 (Electrum RPC)
EXPOSE 3000 4224 50001

# Run electrs with dynamic configuration based on NETWORK and ELECTRS_ARGS
CMD ["sh", "-c", "electrs --daemon-dir /root/.bitcoin -vvvv --http-addr 0.0.0.0:3000 --electrum-rpc-addr 0.0.0.0:50001 $ELECTRS_ARGS"]