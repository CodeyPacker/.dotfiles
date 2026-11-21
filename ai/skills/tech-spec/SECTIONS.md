# Template sections

The sections of the Software Technical Specification template, in interview order. Page order is fixed by the template and differs only in that the Summary is written last.

Each entry gives what belongs in the section, the questions that get there, and when it is done.

## 1. Overview

### 1.2 Background

What exists today and what changed to make this work necessary.

- What does the system or process do today?
- What changed? A customer request, an incident, a deadline, a dependency reaching end of life, growth.
- Why now and not next quarter?

Done when a reader new to the area can say what exists and why this work was raised now.

### 1.3 Problem

The problem in user or business terms, with evidence. No solution here.

- Who has the problem? Name the role or customer.
- What can they not do, or what costs them time or money?
- What is the evidence? Ticket counts, an incident, a measurement, a customer quote.
- What happens if nothing is done?

Done when the problem is stated without naming any technology or fix, and at least one piece of evidence is recorded. If there is no evidence, record that as an open question.

### 1.1 Summary (write last)

Two or three sentences: what is being built, for whom, and the key design decision. Write it from the finished sections and ask the user to confirm it.

## 2. Goals and non-goals

### Goals

Measurable outcomes, numbered `G1`, `G2`.

- How will we know this worked? What number moves, from what to what?
- By when?
- Where is that number measured today?

Done when every goal has a measure and a target. A goal with no measure becomes an open question.

### Non-goals

What the work deliberately leaves out, and why.

- What will people assume is included that is not?
- What related problem are we choosing not to solve here, and why?

Done when each non-goal has a reason.

## 3. Requirements

### PRD

Link to the Product Requirements Document. If none exists, say so on the page.

### Functional requirements

Core user workflows, system behaviors, business logic, and error-handling rules. Numbered `FR-1`, `FR-2`. One testable behavior each.

- Walk the main workflow step by step. What does the user do and what does the system do back?
- What are the business rules? Who is allowed, what are the limits?
- What happens on bad input, a timeout, a dependency being down, a duplicate request?
- Which goal does each requirement serve?

Done when every goal is covered by at least one requirement and every workflow has its error cases written.

### Non-functional requirements

Measurable targets for latency, throughput, uptime, scalability, and security compliance. Numbered `NFR-1`, `NFR-2`. Each has a number and how it is measured.

- What response time is acceptable, at which percentile, under what load?
- What uptime is required? What is the cost of an hour down?
- How much growth must it handle, over what period?
- Which security or compliance commitments apply? Ask the user to confirm these with the security team instead of assuming them.

Done when each target has a number and a measurement method, or is recorded as an open question.

## 4. Proposed solution and system architecture

Include only the subsections that apply (backend, frontend, desktop, or a mix). Delete the rest.

Before the subsections, ask what other approaches were considered and why this one was chosen. Record the answer at the top of the architecture overview.

### 4.1 Architecture overview

Main components and how they interact, with a diagram.

- What are the components, and which are new and which change?
- Trace one request or user action through them.
- Where does state live?

Done when the diagram matches the trace and the user confirms it.

### 4.2 Data model and storage

Entities, databases or local storage, schema changes and migrations.

- What entities are added or changed? Which fields?
- Is existing data migrated? How long does it take, and can it run while the system is live?
- What is retained and for how long?

### 4.3 APIs and interfaces

Endpoints, events, IPC, or public interfaces this work adds or changes.

- What is added, changed, or removed? Give request and response shapes.
- Who calls it? Does any change break an existing caller?
- How is it versioned?

### 4.4 UI and user flows

Screens, navigation, and state management, with links to designs.

- Which screens are new or changed? Link the designs.
- What are the loading, empty, and error states?
- Where is UI state kept?

### 4.5 Integrations and dependencies

Third-party services, libraries, OS or platform APIs.

- What new dependency is added, and what does it cost in licensing, limits, and failure modes?
- What happens when it is unavailable?

### 4.6 Platform and environment

Supported browsers, OS versions, or devices. Hosting. Packaging, installers, and updates.

### 4.7 Performance

Expected load or usage, targets for response, render, or startup time, memory and CPU limits, caching, and how each will be measured. Tie each target to an `NFR` ID.

### 4.8 Security considerations

Authentication, authorization, data protection.

- Who can call or see this, and how is that enforced?
- What sensitive data is stored, sent, or logged? How is it protected?
- What can a malicious or mistaken caller do?

Done for section 4 when every functional requirement can be traced to a component that implements it.

## 5. Deployment

### 5.1 Testing strategy

Unit, integration, end-to-end, performance, and security testing. Acceptance criteria mapped to requirement IDs.

- For each `FR` and `NFR`, what test proves it?
- What cannot be tested automatically, and who tests it by hand?

Done when every requirement ID appears in the acceptance table.

### 5.2 Deployment and rollback

Rollout phases and feature flags, data migration steps, rollback triggers and procedure.

- Who gets it first? What is the phase order?
- What signal means roll back, and who decides?
- Can the data migration be undone? If not, what is the plan?

### 5.3 Monitoring and alerting

Key metrics and dashboards, alert thresholds, on-call owner, runbook link.

- Which metric shows it is working? Which shows it is failing?
- What threshold pages someone, and whom?
- Where is the runbook?

Done for section 5 when a rollback trigger, its procedure, and an on-call owner are named.
