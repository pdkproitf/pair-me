---
name: bb-auth-setup
description: Configure Bitbucket API authentication for the bb-pr-* scripts
argument-hint: ""
---

# bb-auth-setup Skill

This skill automates the setup of Bitbucket API authentication required for using the `bb-pr-*` scripts (bb-pr-create, bb-pr-merge, bb-pr-list, etc.).

## When to Use This Skill

Use this skill when:
- Setting up Claude Code for this workflow for the first time
- You get "Bitbucket authentication failed" errors from `bb-pr-*` scripts
- Your Bitbucket API token has expired (max 365 days)
- You need to upgrade from deprecated Bitbucket app password to Atlassian API token
- You need to reconfigure the `BITBUCKET_AUTH` environment variable

**Prerequisites**:
- You have a work email address on the Bitbucket workspace
- You have access to an Atlassian account (id.atlassian.com)
- Your shell auth file (e.g. `~/.shell/bitbucket-auth`) exists or can be created

## Overview

The skill performs this workflow:
1. Checks if `BITBUCKET_AUTH` is already configured (detects deprecated app passwords)
2. Opens browser to Atlassian API token creation page
3. Prompts for your work email address
4. Prompts for the API token you just created
5. Updates your shell auth file with the authentication export
6. Instructs you to reload your shell profile

**Note**: This configures authentication for Bitbucket operations across all projects that use these scripts.

## Usage

Call this skill with no arguments:

```bash
/bb-auth-setup
```

The skill will interactively guide you through:
1. **Token creation** - Opens browser to create token
2. **Email input** - Your work email address
3. **Token input** - The API token from Atlassian
4. **Configuration** - Updates your shell auth file

## What Gets Configured

### Shell auth file (e.g. `~/.shell/bitbucket-auth`)

Adds or updates this line:

```bash
export BITBUCKET_AUTH="your.email@example.com:your-api-token-here"
```

This environment variable is used by all `bb-pr-*` scripts for Bitbucket API authentication.

## Token Creation Steps

The skill will guide you through these steps on Atlassian's website:

1. **Go to**: https://id.atlassian.com/manage-profile/security/api-tokens
2. **Click**: "Create API token"
3. **Label**: "bitbucket-cli" (or similar)
4. **Expires on**: Set to 1 year from now (max allowed)
5. **App**: Select "Bitbucket"
6. **Scopes**: Select ALL scopes (required for full bb-pr-* functionality)
7. **Copy**: Copy the generated token immediately (you can't view it again)

## Required Scopes

For full `bb-pr-*` functionality, select these scopes when creating your Atlassian API token:

**Repository access**:
- `read:repository:bitbucket` - Read your repositories
- `write:repository:bitbucket` - Write to your repositories
- `admin:repository:bitbucket` - Administer your repositories (required for bb-pr-merge)

**Pull request access**:
- `read:pullrequest:bitbucket` - Read your pull requests
- `write:pullrequest:bitbucket` - Write to your pull requests

**Webhook access**:
- `read:webhook:bitbucket` - Read your webhooks
- `write:webhook:bitbucket` - Write to your webhooks

**Issue access**:
- `read:issue:bitbucket` - Read your issues
- `write:issue:bitbucket` - Write to your issues

**Account and workspace access**:
- `read:account:bitbucket` - Read your account information
- `read:workspace:bitbucket` - Read your workspaces

**Important**: Missing scopes will cause specific operations to fail. Select ALL the scopes listed above for full bb-pr-* functionality.

## Token Security

**CRITICAL SECURITY NOTES**:
- Tokens grant full access to your Bitbucket account
- Never commit tokens to git repositories
- Never share tokens in Slack, email, or documentation
- Rotate tokens annually (365-day max lifetime)
- If compromised, revoke immediately at id.atlassian.com

**Storage location**: your shell auth file should be gitignored in your home directory git repo (if applicable).

## Testing Authentication

After configuration, test with:

```bash
# Reload shell to pick up new env var
reload

# Test authentication by listing PRs
bb-pr-list

# Or check the env var is set
echo $BITBUCKET_AUTH | cut -d: -f1  # Should show your email
```

## Troubleshooting

**Issue**: "Permission denied" when trying to write to your shell auth file
**Solution**: Check file permissions: `ls -la ~/.shell/bitbucket-auth`. Should be readable/writable by you.

**Issue**: API token expired
**Solution**: Tokens expire after 365 days. Run this skill again to create a new token.

**Issue**: Using deprecated Bitbucket app password instead of API token
**Solution**: Bitbucket app passwords (short, 20-30 char tokens) are deprecated. You need an Atlassian API token (200+ chars). Run this skill to upgrade - it will detect the old format and guide you through creating a proper API token.

**Issue**: bb-pr-* still says "authentication failed" after setup
**Solution**: Make sure you ran `reload` to refresh your shell environment.

**Issue**: Token was copied incorrectly
**Solution**: Tokens are long strings. Verify you copied the entire token. Run skill again if needed.

**Issue**: Scopes were not selected correctly
**Solution**: Go back to id.atlassian.com, delete the token, create a new one with ALL scopes selected.

## Related Documentation

- Your team's internal wiki page on Bitbucket API token setup, if one exists
- [GLOBAL: GIT_CONVENTIONS.md](../../knowledge/GIT_CONVENTIONS.md#creating-pull-requests)

## Implementation Notes

The skill should:

1. **Check current configuration**:
   ```bash
   if [[ -n "$BITBUCKET_AUTH" ]]; then
     email=$(echo "$BITBUCKET_AUTH" | cut -d: -f1)
     token=$(echo "$BITBUCKET_AUTH" | cut -d: -f2)
     token_length=${#token}

     echo "Current configuration found for: $email"

     # Detect deprecated Bitbucket app passwords vs. Atlassian API tokens
     if [[ $token_length -lt 100 ]]; then
       echo "⚠️  WARNING: This appears to be a deprecated Bitbucket app password"
       echo "   App passwords are no longer supported. You need an API token."
       echo "   Let me help you update to an Atlassian API token..."
       # Proceed with reconfiguration automatically
     elif [[ $token_length -gt 100 ]]; then
       echo "✓ Current configuration appears to be an Atlassian API token (length: $token_length chars)"
       # Ask if user wants to reconfigure anyway
     else
       echo "⚠️  Token format unclear (length: $token_length chars)"
       # Ask if user wants to reconfigure
     fi
   fi
   ```

   **Token format detection**:
   - **Bitbucket App Passwords (deprecated)**: 20-30 chars, simple alphanumeric
   - **Atlassian API Tokens (current)**: 200+ chars, base64-like with dots, often starts with `ATATT`
   - Tokens under 100 chars are likely deprecated app passwords and should be replaced

2. **Open browser to token creation page**:
   ```bash
   # Use Bash tool to open browser
   open https://id.atlassian.com/manage-profile/security/api-tokens
   ```

3. **Display token creation instructions**:
   - Show clear, numbered steps
   - Emphasize selecting ALL scopes
   - Warn to copy token immediately

4. **Prompt for email and token**:
   - Use `AskUserQuestion` to get email (offer current git config email as default)
   - Use `AskUserQuestion` to get token (sensitive data, mask in logs)
   - Validate format: email should look like a real address for your Bitbucket workspace's domain
   - Validate token is non-empty and looks like a token (no spaces, reasonable length)

5. **Update the shell auth file**:
   - Use `Read` tool to read current file
   - Check if the `BITBUCKET_AUTH` line already exists
   - If exists: Use `Edit` tool to replace the line
   - If not exists: Use `Edit` tool to append the line at the end
   - Preserve all other content in the file

6. **Pattern for updating the shell auth file**:
   ```bash
   # If line exists, replace it
   export BITBUCKET_AUTH="old@example.com:old-token"
   # Replace with:
   export BITBUCKET_AUTH="new@example.com:new-token"

   # If line doesn't exist, append to end of file:
   # (add blank line if file doesn't end with newline)

   export BITBUCKET_AUTH="email@example.com:token"
   ```

7. **Verify the update**:
   - Use `Read` tool to read the file again
   - Confirm the export line is present
   - Show user a masked version: `BITBUCKET_AUTH="email@example.com:***MASKED***"`

8. **Instruct user to reload**:
   ```bash
   # Tell user to run:
   reload
   # Then test with:
   bb-pr-list
   ```

9. **Error handling**:
   - Check if the shell auth file exists (should exist if it was already set up)
   - If not exists, create it with proper header comment
   - Handle case where user cancels midway
   - Validate email format (contains @ and .com/.net)
   - Validate token is non-empty

10. **Security considerations**:
    - Never echo the full token in output (mask it)
    - Warn user about token security
    - Remind about 365-day expiration
    - Don't commit this file if it's in a git repo

## Example Session

```
User: /bb-auth-setup

Claude: I'll help you set up Bitbucket API authentication.

Checking current configuration...
No BITBUCKET_AUTH found. Let's set it up.

Opening your browser to create an API token...
[Opens https://id.atlassian.com/manage-profile/security/api-tokens]

Follow these steps on the Atlassian page:
1. Click "Create API token"
2. Label: "bitbucket-cli"
3. Expires on: 1 year from now
4. App: Bitbucket
5. Scopes: Select ALL scopes
6. Click "Create"
7. Copy the token immediately (you won't see it again)

[Prompts for email - defaults to git config user.email]
What is your work email address?
> jane.doe@example.com

[Prompts for token]
Paste the API token you just created:
> [user pastes token]

Configuring your shell auth file...
✓ Updated ~/.shell/bitbucket-auth with BITBUCKET_AUTH

Configuration complete! Now run:
  reload

Then test your authentication:
  bb-pr-list

Your token expires in 365 days. Run /bb-auth-setup again when it expires.
```

## Team Conventions

This skill follows common team conventions for Bitbucket auth:
- Uses an existing shell auth file if your provisioning tooling already created one
- Integrates with a `reload` shell function
- Follows security best practices for token storage
- Provides clear testing steps
- Links to your own internal documentation, if any
