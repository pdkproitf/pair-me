# commit

> Group changed files by logical concern and generate a Conventional Commits message for each group.

---

## What it does

`commit` analyzes a git diff, groups file changes by logical concern, and produces a properly formatted [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) message for each group. If asked to commit, it executes the commits sequentially after confirmation.

Each group represents one logical, shippable unit of work — not one commit per file. Grouping strategies include: by feature, by layer (app vs. config vs. spec), by component, or by change type (docs separate from code).

Commit messages follow these rules:
- Type prefix required (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, etc.)
- Subject in lowercase, imperative mood, max 72 characters, no trailing period
- Optional scope in parentheses (e.g. `fix(parser):`)
- Body explains what and why, max 100 chars per line
- Breaking changes marked with `!` and/or `BREAKING CHANGE:` footer

---

## When to use

- After completing a phase in `implement`
- At the end of any coding session before pushing
- When `save_progress` needs to commit WIP changes
- Any time you want consistent, well-structured commit messages

---

## Install

```bash
npx skills add pdkproitf/skills@commit
```

---

## Usage

**Claude Code:**
```
/commit
/commit and commit
```

**Other tools:**
```
@commit
@commit and commit
```

Adding "and commit" triggers the actual `git commit` after showing you the grouped messages and getting confirmation.

---

## Output

```
## Group 1: add retry logic to API client
- lib/api_client.rb
- spec/lib/api_client_spec.rb

feat(api-client): add configurable retry logic with exponential backoff

---

## Group 2: update configuration
- config/api.yml

chore(config): add retry_count and retry_delay defaults
```
