# QKD Studio

**A reproducible discrete-time testbed for service-management and closed-loop control experiments in quantum-key-distribution networks.**

QKD Studio is a cross-platform research simulator that studies quantum key
distribution (QKD) at the *service-management* layer — key-pool planning,
routing and scheduling of key demand, service continuity under bursty traffic,
and resilience under attack — rather than at the physical or entanglement
fidelity layer targeted by most existing quantum-network simulators. It pairs a
geospatial topology editor with a deterministic, seeded Rust engine and exposes
a local REST/WebSocket control API through which external controllers observe
per-tick telemetry and inject management actions.

This work supports the manuscript *“QKD Studio: A Reproducible Discrete-Time
Testbed for Service-Management and Closed-Loop Control Experiments in Quantum
Key Distribution Networks”* (Rahaman and Mahmud), submitted to **IEEE
Transactions on Network and Service Management (TNSM)**.

---

## ⚠️ Code availability

**The source code is not publicly available.** The QKD Studio engine, control
plane, and experiment harness are the subject of an active **patent
application** and are protected by copyright. To preserve the novelty required
for that filing, the implementation is withheld at this time.

What **is** published in this repository:

- 🎥 A **recorded demo walkthrough** of the running application (below).
- 🗂️ The **repository structure** (folder layout only — placeholder directories,
  no source).
- 📄 This research overview and the system/methodology description.

The full artifact (engine, controllers, topologies, datasets, and analysis
scripts) is intended to be released, with an archival DOI, once intellectual-
property protection is secured and the manuscript is published. For collaboration
or evaluation access in the meantime, please contact the authors (below).

---

## Demo walkthrough

https://github.com/muntakim1/qkd-geo-simulator/raw/main/docs/demo/qkd-studio-demo.webm

A short recorded walkthrough of the desktop application: a route-redundant
metropolitan mesh is loaded onto a real-world map, the deterministic engine is
run under a denial-of-key attack, and the dashboard updates per-link key flow
together with live service KPIs (capacity, QBER, application satisfaction). The
video file is at
[docs/demo/qkd-studio-demo.webm](docs/demo/qkd-studio-demo.webm).

## Abstract

Quantum key distribution is moving from point-to-point links toward managed
multi-node infrastructures that deliver cryptographic keys as a service. At
network scale, many operational bottlenecks emerge at the service-management
layer while remaining constrained by physical-layer key generation: key-pool
planning, routing and scheduling of key demand, service continuity under bursty
traffic, and resilience under attack. Existing quantum-network simulators
primarily target physical-, link-, or entanglement-level fidelity and are not
optimized for reproducible service-management benchmarking with explicit run
identities, per-tick service KPIs, and programmable management actions. We
present QKD Studio, a cross-platform discrete-time testbed for reproducible
service-management experiments in QKD networks. It combines a geospatial topology
editor with a deterministic seeded Rust engine modelling channel, protocol,
key-pool, demand, scheduling, and attack dynamics, and exposes a local
REST/WebSocket service-control API through which external controllers observe
per-tick telemetry and inject management actions — including routing, scheduling,
key-budget allocation, and QKD/PQC key-source selection. Every run records a
reproducible identity (seed, configuration hash, engine version) and exports
per-tick datasets.

Using fixed-policy controllers we show that, on a route-redundant metropolitan
mesh under attack, management policy alone moves application satisfaction across
more than an order of magnitude, with statistically significant differences over
30 seeds, while the engine reproduces bit-for-bit and is evaluated on topologies
from 6 to 60 nodes. To validate closed-loop experimentation, we implement a
contextual EXP3 adversarial-bandit controller that selects between QKD and ML-KEM
security arms from only a noisy in-band disturbance estimate while an adaptive
eavesdropper best-responds to the previous action. Against static arms, a
no-context ablation, and a dynamic oracle, the context-aware controller is the
strongest among the evaluated deployable policies, showing that observable
disturbance enables effective crypto-agility.

## Research contributions

- **Service-management abstraction for QKD networks.** A discrete-time model that
  exposes routing, scheduling, key-budget allocation, and key-source selection as
  programmable management actions, decoupled from the physical-layer key-rate
  model.
- **Reproducible run identity.** Every run records its seed, configuration hash,
  and engine version, exports per-tick datasets, and reproduces bit-for-bit.
- **Closed-loop control plane.** A local REST/WebSocket API lets external
  Python/Rust controllers observe per-tick telemetry and inject actions, enabling
  ML/RL experimentation against the live engine.
- **Crypto-agility under an adaptive adversary.** A contextual EXP3
  adversarial-bandit controller selects between QKD and post-quantum (ML-KEM) arms
  from a noisy in-band disturbance estimate against a best-responding eavesdropper.
- **Scale and significance.** Evaluation across topologies of 6–60 nodes with
  statistically significant policy differences over 30 seeds.

## System architecture

QKD Studio is delivered as a cross-platform desktop application. A Tauri host
embeds a system WebView that renders a React/TypeScript frontend, while the
authoritative simulation engine is implemented in Rust.

- **Geospatial editor (frontend).** A MapLibre map on which an experimenter places
  nodes (QKD transmitter/receiver, KME, SAE, trusted relay, optical switch, data
  center, IP router) and draws links over a real-world map; topology is persisted
  as GeoJSON.
- **Deterministic engine (Rust).** A seeded discrete-time core modelling channel,
  protocol, key-pool, demand, scheduling, and attack dynamics. The authoritative
  results, persistence, dataset export, and control-plane bridge require the
  desktop runtime.
- **Service-control plane.** A local Axum REST/WebSocket API exposing per-tick
  telemetry and management-action injection for external controllers.
- **Reproducibility pipeline.** Headless batch runner, recorded run identities,
  per-tick CSV/JSONL datasets, and analysis scripts that regenerate every table
  and figure in the manuscript.

The application is self-contained; the research pipeline (experiments, tools,
results, paper) is a separate layer that consumes the engine’s datasets.

## Modelled capabilities

- GeoJSON topology import/export and validation
- KME, SAE, trusted-relay, optical-switch, data-center, and IP-router placement
- BB84, BBM92, E91 (placeholder), and decoy-state BB84 protocol models
- Channel effects: fiber loss, detector efficiency, dark counts, optical error,
  misalignment, background noise, and attack perturbations
- Demand profiles: constant, sinusoidal, and deterministic random-burst
- Attack scenarios: intercept-resend, detector-noise, fiber-loss-spike, and
  denial-of-key
- Service KPIs: QBER, sifted rate, secret rate, loss, key-pool occupancy,
  denied-key, and application satisfaction
- Management actions: routing, scheduling, key-budget allocation, and QKD/PQC
  key-source selection
- Per-link/per-tick CSV and JSONL research dataset export with recorded run
  identity (seed, config hash, engine version)

## Methodology and model scope

The engine uses practical asymptotic key-rate equations suitable for scenario
comparison and dataset generation. It is intentionally **not** a full
quantum-state density-matrix simulator and does **not** claim production ETSI QKD
compliance. The contribution is positioned at the **management layer**: the
physical and attack models are modular and can be replaced by finite-key-secure
or vendor-specific models without changing the service-management abstractions.

## Service-control API (design)

External controllers interact with a running instance over a local bridge
(default `http://127.0.0.1:8787`). The interface is summarised here for reference;
the implementation is part of the withheld artifact.

REST routes include simulation lifecycle (`reset`, `start`, `pause`, `stop`,
`step`), topology and state management, per-tick metrics and events, dataset
access, ML-action injection (`POST /ml/action`), and attack configuration
(`POST /attack/configure`). WebSocket channels stream telemetry, events, and
ML interactions (`/ws/telemetry`, `/ws/events`, `/ws/ml`).

## Topology schema

Point feature kinds: `qkd_node`, `kme_node`, `sae_node`, `trusted_relay`,
`data_center`, `edge_site`, `application_node`.

Line feature kinds: `qkd_link`, `qkd_fiber_link`, `qkd_free_space_link`,
`classical_link`, `trusted_relay_link`.

## Repository structure

> Directories below are published as **structure only** — placeholders without
> source. They mirror the layout of the full (withheld) project.

```text
src/            React + TypeScript frontend (MapLibre topology editor, UI)
src-tauri/      Rust engine, Axum control plane, Tauri desktop host
topologies/     shared GeoJSON topologies (app + experiments)
configs/        scenario / experiment configuration
examples/       external-controller examples
e2e/            Playwright end-to-end demo spec
experiments/    EXP3 key-source case study (controller, runners, analysis)
tools/          batch runner + paper figure/table generators
results/        generated run outputs and datasets
datasets/       per-tick engine dataset exports
paper/          IEEE TNSM manuscript and assets
docs/           project notes and demo video
```

## Citation

If you reference this work, please cite:

```bibtex
@article{rahaman_qkdstudio_2026,
  author  = {Rahaman, Muntakimur and Mahmud, Azwan},
  title   = {{QKD Studio}: A Reproducible Discrete-Time Testbed for
             Service-Management and Closed-Loop Control Experiments in
             Quantum Key Distribution Networks},
  journal = {IEEE Transactions on Network and Service Management (under review)},
  year    = {2026}
}
```

## Authors

- **Muntakimur Rahaman** — Graduate Student Member, IEEE — `muntakimur.rahaman@student.mmu.edu.my`
- **Azwan Mahmud** (corresponding author) — `azwan.mahmud@mmu.edu.my`

Faculty of Engineering, Multimedia University (MMU), Cyberjaya, Selangor, Malaysia.

## License and status

© 2026 the authors. All rights reserved. The source code is **not** licensed for
use, reproduction, or distribution and is withheld pending patent and copyright
filing. This repository publishes only the project overview, structure, and demo
video. Please contact the authors for collaboration or evaluation access.
