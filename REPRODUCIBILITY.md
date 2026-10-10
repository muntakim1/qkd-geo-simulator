# Reproducing the results of the paper

This guide shows how to regenerate every table and figure of the QKD Studio paper
from the published container image, and how to check a run made in the desktop
application against a headless run. The image contains the compiled engine and the
compiled experiment programs; it contains no source code.

## 1. One command

```bash
git clone https://github.com/muntakim1/qkd-geo-simulator.git
cd qkd-geo-simulator
bash docker/reproduce.sh
```

`docker/reproduce.sh` picks the image for your processor (`amd64` or `arm64`),
downloads it from the [v0.3.0 release](https://github.com/muntakim1/qkd-geo-simulator/releases/tag/v0.3.0),
verifies its SHA-256 checksum, loads it into Docker, and runs it with `./qkd-output`
mounted for the results.

## 2. Manual steps

```bash
# choose amd64 (Intel/AMD) or arm64 (Apple silicon, ARM servers)
ARCH=amd64
BASE=https://github.com/muntakim1/qkd-geo-simulator/releases/download/v0.3.0
curl -fLO "$BASE/qkd-studio-repro_0.3.0_linux-$ARCH.tar.gz"
curl -fLO "$BASE/SHA256SUMS.txt"
sha256sum --check --ignore-missing SHA256SUMS.txt     # macOS: shasum -a 256 -c --ignore-missing

docker load -i "qkd-studio-repro_0.3.0_linux-$ARCH.tar.gz"
mkdir -p qkd-output
docker run --rm -v "$PWD/qkd-output:/output" qkd-studio-repro:0.3.0
```

With Docker Compose, after the `docker load` step:

```bash
docker compose -f docker/docker-compose.yml up
```

## 3. What the run does

| Step | Result in the paper |
|---|---|
| Controller unit tests (15) | |
| Routing-by-scheduler grid, 720 runs | Table IV |
| Denial-of-key sweep, 3600 runs | Fig. 5 |
| Load and PQC-capacity sweeps | Figs. 3 and 4 |
| Disturbance types and demand profiles | Fig. 6 |
| Model sensitivity, 1800 runs | Table V |
| Single-run trace, throughput | Supplementary Figs. S1 and S2 |
| Key-source study, 160 runs of 10 000 intervals | Table VI, supplementary Table S-I, Figs. S3 and S4 |
| Key-source sensitivity sweep, 2520 runs | Supplementary Table S-II |
| Controller through the REST interface | Supplementary Table S-III |
| Determinism and run-record checks | |
| Comparison with the reported values | |

A successful run ends with:

```text
All 14 regenerated outputs match the shipped results.
Reproduction workflow completed successfully.
```

It takes about 8 minutes on an Apple-silicon laptop, and two to three times as long
when Docker has to emulate the processor architecture of the image.

## 4. What is checked

- **Reported values.** Fourteen regenerated tables and data files are compared with
  the values recorded in the image. The comparison fails if any text differs or if
  any number differs by more than a last-digit rounding tolerance, and reports each
  file as `identical`, `within tolerance`, or `MISMATCH`.
- **Determinism.** One configuration is run twice with the same seed; the two
  per-tick datasets must be byte-identical apart from the wall-clock timestamp and
  the random run identifier.
- **Run records.** A run writes a record of its identity and result; replaying the
  record must reproduce it, and a record with an altered digest must be rejected.
- **Control plane.** The key-source controller run through the REST interface must
  make the same decisions as the same controller run directly.

The engine's own unit tests, including the tests that key is conserved for every
combination of routing policy, scheduler, and fallback setting, are run when the
image is built and cannot be rerun without the source.

Throughput (supplementary Fig. S2) depends on the machine and is the only result that
is not compared.

## 5. Output

`qkd-output/results/` contains the data behind every table and figure as CSV and
JSON-lines files, and `qkd-output/paper/` contains the generated LaTeX table
fragments and the figures as PDF files.

## 6. Checking a run made in the desktop application

Every finished run in the application has a *run record*: the engine version, the
seed, a hash of the topology, a hash of every setting that can change the result, a
digest of the result, and the complete run specification.

1. Install the application (see the [README](README.md)).
2. In the **Scenario** tab choose **Policy-study mesh**, set the factors you want
   (demand, seed, disturbance, routing, scheduler, PQC fallback, key-rate and
   post-processing models), and press **Run**.
3. In the **Research** tab press **Export record**.
4. Replay the exported file with the engine in the container:

```bash
docker run --rm -v "$PWD/my-run.record.json:/record.json:ro" qkd-studio-repro:0.3.0 \
  src-tauri/target/release/batch_runner /record.json
```

The command prints a one-line summary containing `"replay_matches": true` and exits
with status 0 if the headless engine reproduces the identity and the result digest of
the run made in the application. It exits with status 2 if it does not.

A record is replayable only if the run completed without external changes. Actions
sent through the REST interface during a run are counted in the record, because the
specification alone then no longer describes the run. The application and the image
must have the same engine version.

## 7. Scope

The key-rate equations are asymptotic and the disturbances are parametric stress
tests; neither is a calibrated device model or a security proof. The results are
relative comparisons within the released scenarios.
