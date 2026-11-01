# Tour stops

Each stop has a goal and the evidence that grounds it. Every claim on a stop cites a file you read.

## High-level tour

For someone who wants to know what the repo is and does, not how the code works. Keep code excerpts out. File mentions are fine.

| Code | Stop | Covers |
| --- | --- | --- |
| H1 | Purpose | What the repo is, who uses it, and the one job it exists for. |
| H2 | Problems solved | The concrete problems it removes for its users, in their terms. |
| H3 | Tech stack | Languages, frameworks, datastores, and infrastructure, each with the manifest or config that proves it. |
| H4 | Services and interfaces | What a user or another system can reach: APIs, web UIs, CLIs, background jobs, libraries. For each, how it is started and where it lives. |

Evidence: README and docs, manifests (`package.json`, `*.csproj`, `pyproject.toml`, `go.mod`), Dockerfiles and compose files, deploy config, route and controller definitions, CLI entry points.

## Technical tour

Outside in: how the repo is laid out and run, then one real flow traced through the code.

| Code | Stop | Covers |
| --- | --- | --- |
| T1 | Layout and run | Top-level folders and what each owns. Commands to install, run, and test locally. |
| T2 | Entry points | Where execution starts, where config loads, where dependencies are wired. |
| T3 | Architecture | Modules or layers, what each owns, and which way dependencies point. |
| T4 | Trace one flow | One real feature followed hop by hop from input to output, with `file:line` at every hop. |
| T5 | Data model | Core entities, schemas, migrations, where state lives. |
| T6 | Integrations | External APIs, queues, caches, auth providers, and where each is wrapped. |
| T7 | Cross-cutting | Auth, error handling, logging, validation, secrets and config handling. |
| T8 | Tests and CI/CD | Test layout, how to run tests, what the pipeline does, how deploys happen. |
| T9 | Hot spots | Most-changed files (from `git log --name-only`), conventions new code must follow, problems found while reading as F1, F2, ... |
| T10 | Where to start | Three to five files to read in order, and one small first change. |

T4 carries the tour. Pick a flow a new contributor would touch in their first week, and trace every hop.

## Adapting to the repo type

Classify the repo before choosing stops. When a stop has no subject in this repo, replace it with the closest real subject and mark it adapted in the rail. When nothing fits, state in one line why the stop is empty (T8: "No tests or CI config exist.") rather than dropping it.

| Repo type | T4 | T5 | T6 |
| --- | --- | --- | --- |
| Service or web app | A request, route to response | Schemas and migrations | External APIs, queues |
| Library | One public call, API to result | Core types | Peer dependencies |
| CLI | One command, argv to output | Config and state files | Shells and tools it invokes |
| Config or dotfiles | One setting, from where it is set to every place it is read | Link or install map | Package sources and remote installers |
| Monorepo | One flow crossing packages | Shared types or schemas | Package boundaries and shared infra |
