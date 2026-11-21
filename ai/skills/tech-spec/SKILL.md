---
name: tech-spec
description: Write or update a Software Technical Specification from the team template by grilling the user section by section and publishing the spec as an artifact that is updated in place. Use when the user asks for a tech spec, technical specification, or design doc for a task, or wants to continue, update, or review an existing one.
---

A tech spec is built in two parts that run together. The conversation is an interview where you question the user until each section of the team template has a real answer. The page is one artifact that holds the spec, republished to the same URL after every section so the user and reviewers always see the current state.

Every statement in the spec comes from the user, from code you read in this session, or from a document the user gave you. Anything else is an open question on the page, never a guess written as fact.

## 1. Start or resume

**Resume** when the user gives an artifact link or names a spec that already exists. Find it with `Artifact` `action: "list"` if you have no link, then `action: "read"` it and work from the saved file the read names. Load `ArtifactComments` through `ToolSearch` and read the comments on it. Tell the user what is open: each open question (`Q` codes on the page) and each unanswered comment. Continue at step 3 with those.

**New** otherwise. Get three things before the first interview question:

- The task in one or two sentences, in the user's words.
- The PRD or ticket, if one exists. Read it.
- The code the task touches, when you are in a repository. Read it so you can ask about what is there, and answer your own questions where the code already answers them.

Done when you can state the task back to the user and they agree.

## 2. Create the page

Copy [`template.html`](template.html) to the scratchpad as `<task-slug>-tech-spec.html`. Fill the header and document information: status `Draft`, today's date, the author from `git config user.name` or the user's answer, effort `TBD`. Leave every subsection as the template's "Not discussed yet" line. Remove the reviewer rows that have no name yet only after the user says who reviews.

Read [`SECTIONS.md`](SECTIONS.md). It lists every template section, what belongs in it, the questions that get there, and when the section is done.

Publish the first version after the Overview section is done, not before. Call `Artifact` with `action: "quickstart"`, `intent: "other"`, `design_systems: false`, then publish the file with `icon: "document"`. The template already meets the page contract, so keep its CSS and script unchanged.

## 3. Grill

Work through the sections in the order `SECTIONS.md` gives. The problem comes first and the summary is written last, because the summary states the key design decision and that is not known until the solution is.

How to ask:

- One question per message. Wait for the answer.
- Give your recommended answer with each question when you have a basis for one, so the user can confirm or correct instead of writing from nothing.
- Before asking, check whether the code, the PRD, or an earlier answer already settles it. If it does, state what you found and ask only for confirmation.
- Do not accept an answer that cannot be checked. "Fast", "secure", "scalable", "users want it" each get a follow-up: what number, measured how, which users, what evidence.
- Challenge the answer when it conflicts with the code, the PRD, or something the user said earlier. Name the conflict.
- Keep solution talk out of the Problem section and problem talk out of the solution. When the user jumps ahead, note the point and return to it in its own section.
- When the user does not know, record an open question with an owner and move on. Do not stall the interview on it.
- When a section's "done when" in `SECTIONS.md` is met, say so in one line and move on. Do not keep asking past it.

In section 4, include only the subsections that apply to the project. Propose which ones apply from what you read and let the user correct the list. Delete the rest from the page and its rail.

## 4. Update the page

After each top-level section is done, write it into the file and publish again with the same file path, which keeps the URL. In a later session, pass the artifact's `url` instead.

- Build content from the components documented in the template's comment block.
- Number requirements `FR-1`, `NFR-1` and goals `G1`. Never renumber one after it is published, because the testing table and reviewers refer to them. Retire an ID by striking it through with a reason.
- Open questions are `Q1`, `Q2` and sit in the section they block. When one is answered, replace it with the answer.
- Add one line to the change log for each publish after the first: date and what changed.
- Draw the architecture diagram as a `<pre class="mermaid">` block from components the user confirmed.

After each publish, send one chat line: the section that changed, the artifact link with the section anchor, and the count of open questions.

Done when `grep -c "{{" <file>` returns 0 before every publish.

## 5. Review and hand off

When all sections are done, write the Summary, set the estimated effort with the user (`Low`, `Medium`, or `High`), and fill the review table with the approvers the user names, each `Pending`.

Then read the whole spec once as a reviewer would and report gaps to the user as findings (`F1`, `F2`): a goal with no requirement, a requirement with no acceptance criterion in the testing table, a non-functional target with no way to measure it, a migration with no rollback step. Fix what the user answers and publish.

Change the status to `In review` only when the user says to send it for review, and to `Approved` only when the user says every approver has signed off. Update one approver's row when the user reports that person's decision.

Finish with one line: the artifact link, the status, and the number of open questions left.
