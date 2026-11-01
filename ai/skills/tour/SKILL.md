---
name: tour
description: Give a guided tour of a code repository, high-level or technical, published as an artifact and walked stop by stop in chat. Use when the user asks for a tour, walkthrough, or orientation of a repo.
---

A tour is a set of stops published as one artifact page, then walked one stop at a time in chat. The page holds the full content. Chat holds the conversation: a short summary per stop, then a pause where the user picks what happens next.

Every claim on a stop is grounded: it cites a file you read in this session, with a line number where one applies. A claim you cannot ground is left out.

## 1. Choose depth

Call `AskUserQuestion` with one question, header `Tour depth`:

- **High-level**: purpose, problems solved, tech stack, services and interfaces.
- **Technical**: layout, entry points, architecture, one flow traced through the code, and on to where to start.

Done when the user has picked one.

## 2. Survey the repo

Read [`STOPS.md`](STOPS.md) for the stops of the chosen depth and how to adapt them to the repo type.

Get the absolute repo root with `git rev-parse --show-toplevel`. Read the README, the manifests, and the entry points, then classify the repo type. For a technical tour also run `git log --name-only --format=` and count changes per file for T9. When the repo has more than a few hundred tracked files, dispatch `Explore` agents in parallel, one per group of stops, and ask each for files and line numbers rather than prose.

Done when every stop has content, every `file:line` you will cite was read in this session, and every adapted stop names its substitute subject.

## 3. Build and publish the page

Copy [`template.html`](template.html) into the scratchpad as `<repo-name>-tour.html`. Fill it:

- One rail link and one `<section class="stop">` per stop. Ids are the lowercase stop code (`h1`, `t4`).
- Build each stop body from the components documented in the template's comment block.
- Mark every repo file mention as `<code class="f">relative/path:line</code>`, relative to the repo root. Source lines under excerpts go in `<span class="src">`.
- Keep the template's CSS and script unchanged.

Done when `grep -c "{{" <file>` returns 0. Then call `Artifact` with `action: "quickstart"`, `intent: "other"`, `design_systems: false` (the tool requires it), and publish the file with `icon: "map"`. The template already meets the page contract, so publish it as built.

## 4. Walk the stops

For each stop, send one chat message:

- The stop code and title, then two to four sentences on what matters most at this stop.
- A link to the stop: `<artifact url>#<stop id>`.

Then call `AskUserQuestion` with one question, header `Next`, "Where next?", and `multiSelect: true`. Options: **Continue**, **Go deeper**, **Skip ahead**, and **Open files in VS Code**. The user can also type a question through Other.

Open files is for code worth reading in an editor: source files the stop cites at a specific line, such as an excerpt's source or a hop in a trace. Docs, READMEs, agent context files, manifests, and lockfiles stay on the page. Offer the option only when the stop has at least one such file, and list those files in its description. High-level tours rarely qualify.

When Open files is selected, run `code -g "<repo root>/<path>:<line>"` once per listed file, up to six. If `code` is not on PATH, say so and list the paths. Open files alone means open them and pause on the same stop again.

Then handle the move. When several moves are selected, Go deeper wins over Skip ahead, and Skip ahead wins over Continue.

- **Continue**: move to the next stop.
- **Go deeper**: read further into this stop's files, answer in chat with `path:line` references, then pause on the same stop again.
- **Skip ahead**: ask which stop with `AskUserQuestion`, offering up to four upcoming stops. Other covers the rest.
- **A typed question**: answer it, then pause on the same stop again.

When Go deeper or a question turns up something a later reader would want, add it to that stop's section and republish the same file path, which keeps the URL.

## 5. Finish

After the last stop, send one line with the artifact link and the number of findings. On a high-level tour, the final pause offers **Start technical tour** in place of Continue, which restarts at step 2 with the technical stops and publishes a new page.
