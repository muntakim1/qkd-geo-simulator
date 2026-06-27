# QKD Studio

QKD Studio is a Rust/Tauri desktop simulator for geospatial quantum-key-distribution research. It combines a MapLibre GeoJSON topology editor with a deterministic QKD channel engine, key-pool consumption model, research dataset recorder, persistent simulator states, and a local ML/RL control API.

## Quick demo

```bash
npm install
npm run dev          # browser preview at the printed localhost URL
```

Then **Run** the pre-loaded mesh scenario and watch per-link key flow and the
service KPIs (capacity, QBER, satisfaction) update live. For the full desktop
experience (persistent states, dataset export, REST/WebSocket bridge) use
`npm run tauri dev` instead. A recorded walkthrough is in
[docs/demo/qkd-studio-demo.webm](docs/demo/qkd-studio-demo.webm).

**New to QKD topology?** Work through [examples/topologies/GUIDE.md](examples/topologies/GUIDE.md)
— seven short, importable example networks that together cover every palette element,
link type, protocol, and scenario. Drag any `.geojson` from
[examples/topologies/](examples/topologies/) onto the map to load it.

## Implemented capabilities

- GeoJSON topology import/export and validation
- KME, SAE, trusted-relay, and data-center node placement
- Drag-to-reposition nodes with automatic link distance updates
- GNS3-style QKD appliances with quantum and classical connection ports
- Drag-port-to-port fiber creation plus click-two-nodes link creation
- Node and channel property editing
- BB84, BBM92, E91 placeholder, and decoy-state BB84 models
- Fiber loss, detector efficiency, dark counts, optical error, misalignment, background noise, and attack effects
- Constant, sinusoidal, and deterministic random-burst demand
- Intercept-resend, detector-noise, fiber-loss-spike, and denial-of-key scenarios
- Run, pause, stop, reset, step, and fast-forward controls
- Seeded deterministic simulation
- QBER, sifted rate, secret rate, loss, key-pool, denied-key, and satisfaction metrics
- Key starvation, low-pool, QBER threshold, lifecycle, and ML-action events
- Per-link/per-tick CSV and JSONL research dataset export
- Persistent `.qkdsim.json` states in the platform application-data directory
- Autosave and autosave recovery
- Local Axum REST/WebSocket bridge for external Python/Rust controllers

## Development

Prerequisites:

- Node.js and npm
- Rust 1.87 or newer
- Tauri v2 platform prerequisites

```bash
npm install
npm run tauri dev
```

Frontend-only preview:

```bash
npm run dev
```

The browser preview uses a deterministic local approximation and supports run, step, fast-forward, stop, and reset controls. Persistent states, downloadable research datasets, and the local API bridge require the Tauri desktop runtime.

## Package for macOS

On an Apple Silicon Mac:

```bash
npm install
npm run bundle:macos
```

The generated packages are:

```text
src-tauri/target/release/bundle/macos/QKD Geo Simulator.app
src-tauri/target/release/bundle/dmg/QKD Geo Simulator_0.1.0_aarch64.dmg
```

The default build uses a valid ad-hoc macOS signature. It is suitable for local
testing, but another Mac may still require right-clicking the app and selecting
**Open**, or approving it under **System Settings → Privacy & Security**.
Public distribution without warnings requires a Developer ID Application
certificate and Apple notarization.

The research-only batch runner is intentionally excluded from application
bundles. Build it explicitly with:

```bash
cd src-tauri
cargo build --release --features batch-runner --bin batch_runner
```

## Validation

```bash
npm run build
cd src-tauri
cargo test --locked
cargo fmt --check
cargo clippy --all-targets --locked -- -D warnings
```

## Topology schema

Supported point feature kinds:

- `qkd_node`
- `kme_node`
- `sae_node`
- `trusted_relay`
- `data_center`
- `edge_site`
- `application_node`

Supported line feature kinds:

- `qkd_link`
- `qkd_fiber_link`
- `qkd_free_space_link`
- `classical_link`
- `trusted_relay_link`

See [topologies/demo_kl_qkd.geojson](topologies/demo_kl_qkd.geojson) for a complete example.

## Local API bridge

Start the bridge from the Research panel or top toolbar. The default address is:

```text
http://127.0.0.1:8787
```

Core REST routes:

```text
GET  /health
GET  /schema
GET  /topology
POST /topology
GET  /state
POST /state/load
POST /state/save
POST /simulation/reset
POST /simulation/start
POST /simulation/pause
POST /simulation/stop
POST /simulation/step
GET  /simulation/metrics
GET  /simulation/events
GET  /dataset/current
POST /ml/action
POST /attack/configure
```

WebSocket routes:

```text
/ws/telemetry
/ws/events
/ws/ml
```

Python examples are available in [examples/python_ml_listener](examples/python_ml_listener):

```bash
cd examples/python_ml_listener
python -m pip install -r requirements.txt
python listener.py
```

For step-based agent control:

```bash
python rl_agent_stub.py
```

## Repository layout

```text
src/                 React + TypeScript frontend (MapLibre topology editor, UI)
src-tauri/           Rust engine, Axum control plane, Tauri desktop host
public/              static assets served by the dev preview (demo_kl_qkd.geojson)
topologies/          shared GeoJSON topologies (app + experiments)
configs/             scenario / experiment configuration
examples/            external-controller examples (python_ml_listener)
e2e/                 Playwright end-to-end demo spec

experiments/         EXP3 key-source case study (controller, runners, analysis, tests)
tools/               batch runner + paper figure/table generators
results/             generated run outputs, CSV/JSON, EXP3 datasets
datasets/            per-tick engine dataset exports

paper/               IEEE TNSM manuscript: .tex, .pdf, figures, \input tables,
                     paper-assets/, and the packaged submission/ + zip
docs/                project notes (PROJECT_OVERVIEW.md, HANDOFF.md) and demo video
```

The app (top group) is self-contained; the research pipeline (`experiments/`,
`tools/`, `results/`, `paper/`) is separate and not required to run the demo.

## Model scope

The current engine uses practical asymptotic key-rate equations suitable for scenario comparison and dataset generation. It is intentionally not a full quantum-state density-matrix simulator and does not claim production ETSI QKD compliance. The module boundaries are designed for replacing the channel and protocol equations with publication-specific models.
