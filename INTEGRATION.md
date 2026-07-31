# Integration Guide: meta-llama-cpp with yocto-playground

This guide explains how to integrate the `meta-llama-cpp` layer into the Abhishekojha38/yocto-playground repository.

## Overview

The `meta-llama-cpp` layer provides llama.cpp integration with an Ollama-compatible API for running large language models on embedded Linux systems built with Yocto.

## Integration Steps

### 1. Add Layer as Git Submodule

```bash
cd yocto-playground
git submodule add <your-meta-llama-cpp-repo-url> sources/meta-llama-cpp
git submodule update --init --recursive
```

### 2. Update layers.conf

Add to `yocto-playground/layers.conf`:

```
sources/meta-llama-cpp
```

### 3. Update build.conf

Add to `yocto-playground/build.conf` if needed:

```bash
# Add llama-cpp to your image
IMAGE_INSTALL:append = " llama-cpp llama-cpp-server"
```

### 4. Build the Image

Using the existing build system:

```bash
cqfd init
cqfd run
```

### 5. Testing in QEMU

```bash
# For x86-64
runqemu playground-x86 nographic slirp

# For ARM64
runqemu playground-arm64 nographic slirp
```

## Architecture Comparison

### meta-ollama vs meta-llama-cpp

| Feature | meta-ollama | meta-llama-cpp |
|---------|-------------|-----------------|
| Base | Ollama binary (Go) | llama.cpp (C++) |
| Size | Larger (~100MB+) | Smaller (~10MB) |
| Dependencies | Go runtime | Minimal (libc, libstdc++) |
| Performance | Good | Excellent on CPU |
| Memory | Higher | Lower |
| GPU Support | CUDA, ROCm | Limited (CPU-focused) |
| Best For | Desktop/Server | Embedded devices |

## Layer Structure

```
meta-llama-cpp/
├── conf/
│   └── layer.conf              # Layer configuration
├── recipes-llm/
│   ├── llama-cpp/
│   │   └── llama-cpp_git.bb    # Core llama.cpp recipe
│   └── llama-cpp-server/
│       ├── llama-cpp-server_1.0.bb
│       └── files/
│           ├── llama-cpp-server.service
│           ├── llama-cpp-wrapper.sh
│           └── config.json
└── README.md
```

## Runtime Usage

### Starting the Server

```bash
# Using systemd
systemctl start llama-cpp-server
systemctl enable llama-cpp-server

# Check status
systemctl status llama-cpp-server

# View logs
journalctl -u llama-cpp-server -f
```

### API Examples

llama-server exposes an OpenAI-compatible API, not Ollama's native `/api/*` routes
(see `llama-server-api-guide.md` for the full reference):

```bash
# List models
curl http://localhost:11434/v1/models

# Generate text
curl -X POST http://localhost:11434/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain quantum computing",
    "stream": false
  }'

# Chat completion
curl -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

### Adding Models

```bash
# Download a GGUF model
cd /var/lib/ollama/models
wget https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf

# Restart server to detect new model
systemctl restart llama-cpp-server
```

## License

This layer follows the same licensing as llama.cpp (MIT License). Individual recipes may have different licenses - check the LIC_FILES_CHKSUM in each recipe.

## References

- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [Original yocto-playground](https://github.com/Abhishekojha38/yocto-playground)
