# PR body template & example

Referenced by `create-pr/SKILL.md`. Populate the sections from the spec/plan
resolved in the skill's "Source the PR content" step; only re-analyze the diff
if no plan exists.

---

## Template

If the project has its own PR template (e.g. `.github/PULL_REQUEST_TEMPLATE.md`),
follow that instead. Otherwise use:

```markdown
## Summary
### Context
<!-- 1-3 sentences: Provide a clear, concise overview of what problem and why. explain in bullet-->
### Solution
<!-- 1-3 sentences: solution. explain in bullet-->

## Ticket / Issue Link
<!-- spec *.md file link if exist -->

## Related Issue
<!-- Fixes #NNN or Closes #NNN -->

## Changes
<!-- Bullet list of key changes -->

## Testing
<!-- What testing was done? -->
- [ ] Pre-commit / lint checks pass
- [ ] Unit tests added/updated
- [ ] E2E tests added/updated (if applicable)

## Checklist
- [ ] Follows Conventional Commits
```

Check boxes only for steps that were actually completed.

---

## Complete example

```bash
gh pr create \
  --title "feat(cli): add pagination to resource list" \
  --body "$(cat <<'EOF'
## Summary

Add `--limit` and `--offset` flags to `resource list` for pagination.

## Related Issue

Closes #456

## Changes

- Added `offset` and `limit` query parameters to the list API call
- Default limit is 20, max is 100
- Response includes `total_count` field

## Testing

- [x] Pre-commit / lint checks pass
- [x] Unit tests added/updated
- [ ] E2E tests added/updated (if applicable)

## Checklist

- [x] Follows Conventional Commits
EOF
)"
```

The same body text works for any method — pass it as the `body` field to a GitHub
MCP `create_pull_request` call, or as the `"body"` JSON field to
`POST /repos/{owner}/{repo}/pulls`.
