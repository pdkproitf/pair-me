# PR body template & example

Referenced by `create-pr/SKILL.md`. Populate the sections from the spec/plan
resolved in the skill's "Source the PR content" step; only re-analyze the diff
if no plan exists.

---

## Template

If the project has its own PR template — `.github/PULL_REQUEST_TEMPLATE.md` on GitHub,
or `PULL_REQUEST_TEMPLATE.md` in the repo root or `.bitbucket/` on Bitbucket — follow
that instead. Otherwise use:

```markdown
## Problem
<!-- What the user or caller sees go wrong, in 1-2 sentences.
     Then a concrete reproduction as a fenced block: a conversation, a request and
     its response, or a command and its output. Name where it comes from
     ("prompt eval case A2", "ticket PROJ-1234", "staging log").
     End with the correct behaviour in one sentence ("The right answer is ..."). -->

## Why it happens
<!-- Bullets. The root cause, not the symptom, as a chain from mechanism to the
     bad result. Name the file/function where the cause lives. If an existing
     part of the code already handles a similar case, say so here. -->

## Approach
<!-- One sentence: the change itself.
     Then bullets: what changes, where (file + function), and any new option or
     argument with what it does. If a real alternative was rejected, name it in
     one bullet with the reason and evidence. -->

Cost:
<!-- Bullets with numbers: added tokens per request, extra calls, latency, memory.
     Show how the number was found ("chars/4", "capped at 10 messages").
     Write "No extra request" or similar when that is the case. -->

## Results
<!-- 1. Unit tests: passed/failed counts. Compare failures with the base branch
        ("the same 8 tests fail on `main`") and name new tests and what they guard.
     2. Before/after evidence of the change itself, as fenced blocks made by
        running the new code (the prompt, the request payload, the output,
        the SQL). Say how it was made. Add 1-2 bullets on what to see in it.
     3. Measured effect: an eval table (case/suite x variant, passes/total) or
        a benchmark, with the command or harness and the run count.
     4. Bullets: what is fixed, with a quoted example reply/output, and what is
        still open, with a quoted example. Explain any fail that is not a real
        regression. -->

Related: <!-- sibling PRs, ticket, spec file. Omit if none. -->
```

Always write the four sections `Problem`, `Why it happens`, `Approach` (with `Cost`) and `Results`. Every claim in `Results` needs evidence made in this session (test run, rendered output, eval run); never write a number you did not measure. Omit `Related` when there is nothing to link.

---

## Complete example

Based on a real PR (`fix(chat): date earlier chat turns in the reply request`).

```markdown
## Problem

When the user asks about something they said a few turns earlier in the same chat, and names a time, Ava hedges or asks to be reminded, even though the fact is right there in the chat.

Example (prompt eval case A2, companion Sumi on qwen36):

    User: I just got a job as a sous chef at Fig and Ash.
    Sumi: Wow, that is such a big step. ...
    User: I told you about the Fig and Ash job last month, right?
    Sumi: I don't think so, but I can't check my notes right now. Did you mention it before?

The right answer is "You told me just now, not last month."

## Why it happens

- Chat-completions messages carry only `role` and `content`. Omni sends earlier turns with no time.
- Without a time, every earlier turn reads as "now or never". The model cannot see that "I just got a job" was said 6 minutes ago.
- So when the user says "last month", the model assumes an older chat it cannot see, and hedges.

## Approach

Add `dated_history()` in `src/chat/history.py` and use it in the reply path.

- Every earlier turn is led by its age, for example `(6 minutes ago) I just got a job ...`.
- New option `newest_user_bare=True` leaves the message being answered without an age.
- Applied in `src/agent/agent.py` `llm_node` and `src/api/service/inference.py` `complete()`.

Cost:

- About 4 to 6 tokens per earlier message. History is capped at 10 messages, so at most about 50 tokens per request.
- No extra request.

## Results

Unit tests: 6560 passed, 8 failed. The same 8 tests fail on `main`. New test `test_a_chat_reply_leaves_the_message_it_answers_bare`.

Prompt before and after (`messages[]` of the reply request for case A2, made by running `dated_history()` on this branch):

    Before:
    user      | I just got a job as a sous chef at Fig and Ash.
    assistant | Wow, that is such a big step. ...
    user      | I told you about the Fig and Ash job last month, right?

    After:
    user      | (6 minutes ago) I just got a job as a sous chef at Fig and Ash.
    assistant | (6 minutes ago) Wow, that is such a big step. ...
    user      | I told you about the Fig and Ash job last month, right?

- The newest user message has no age.

Prompt eval (`scripts/prompt_eval.py`, x4 per case):

| Suite | qwen36 bare | qwen36 dated | sumi bare | sumi dated |
| --- | --- | --- | --- | --- |
| `time_claims` | 8/9 | 8/9 | 8/9 | 8/9 |

- A2 on sumi: fixed. "You told me about it just now, so I don't remember it from last month."
- A2 on qwen36: still open. It hedges in 1 to 3 of 4 tries.

Related: #354 changes the MEMORY prompt rules for the same ticket (PROJ-2841).
```

The same body text works for any method and either host. Only the field name changes:

| Target                                                               | Field           |
| -------------------------------------------------------------------- | --------------- |
| `gh pr create`                                                       | `--body`        |
| GitHub MCP `create_pull_request`                                     | `body`          |
| `POST /repos/{owner}/{repo}/pulls`                                   | `"body"`        |
| `POST /2.0/repositories/{workspace}/{repo}/pullrequests` (Bitbucket) | `"description"` |

Bitbucket renders `description` as Markdown, so no reformatting is needed. Build that
JSON with `jq` or Python — interpolating this multi-line body into a shell string
breaks on the first quote or newline and returns an opaque `400`.
