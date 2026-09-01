# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this repo is

`meta-llama-cpp` is a Yocto Project / OpenEmbedded BSP layer that builds
[llama.cpp](https://github.com/ggml-org/llama.cpp) for embedded Linux targets,
including a systemd service that runs `llama-server` as a local inference API
daemon. It is consumed as a layer (typically a git submodule) by a Yocto build
such as `yocto-playground`; it is not built on its own.

## Layout

| Path | Purpose |
| --- | --- |
| `conf/layer.conf` | Layer definition: priority, `LAYERDEPENDS`, `LAYERSERIES_COMPAT`. |
| `recipes-llm/llama-cpp/llama-cpp_git.bb` | The only recipe. Builds `llama-cpp` and its extra package `llama-cpp-server`. |
| `recipes-llm/llama-cpp/files/` | Recipe `SRC_URI` files: the impl-lib versioning patch and `llama-cpp-server.service`. |
| `scripts/test-layer.sh` | Layer validation: run from a Yocto build dir after `oe-init-build-env`. |
| `*.md` | User-facing docs (README, QUICKSTART, INTEGRATION, COMPARISON, API guide). |

There is a single recipe. `llama-cpp-server` is a package split out of it via
`PACKAGES =+`, not a separate `.bb` file. A standalone `llama-cpp-server` recipe
existed previously and was deliberately removed — do not recreate it. The
`llama-cpp-models` recipe mentioned in older docs does not currently exist.

## Conventions

- **Recipe style**: follow OpenEmbedded norms — `inherit` after the header vars,
  keep `EXTRA_OECMAKE` entries one-per-line with trailing `\`, use override
  syntax (`do_install:append`, `FILES:${PN}`, `RDEPENDS:${PN}-server`).
- **Upstream bumps**: update both `SRCREV` and `LIC_FILES_CHKSUM` if the
  upstream `LICENSE` file changes. `PV`/versioning is git-based (`_git.bb`).
- **Comments**: explain *why* a flag is set, as with the `GGML_CPU_ARM_ARCH`
  block that documents the Cortex-A55 dotprod targeting and its portability
  caveat. Keep that altitude — a future reader on a different SoC needs it.
- **`LAYERSERIES_COMPAT`**: keep in sync with the Yocto releases actually
  tested. Currently `walnascar scarthgap nanbield mickledore kirkstone`.
- Keep the docs in sync when recipe behavior changes (package names, install
  paths, service config, model directory `${datadir}/edgeai/models`).

## Validating changes

There is no build CI in this repo. Meaningful validation requires a Yocto build
environment, which is not available here:

```bash
# from a Yocto build directory, after: source oe-init-build-env
bitbake-layers add-layer /path/to/meta-llama-cpp
../meta-llama-cpp/scripts/test-layer.sh   # parse / dependency / dry-run checks
bitbake llama-cpp                          # full build
```

When you cannot build, sanity-check recipe syntax by eye and state clearly in
your summary that the change is unbuilt.

## Git

- Branch for changes; open a PR against `main` (see recent history for the
  `recipes-llm/<topic>` branch naming pattern).
- Commit and push only when asked.
