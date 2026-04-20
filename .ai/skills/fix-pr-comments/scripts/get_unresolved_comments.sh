#!/usr/bin/env bash
# Fetches unresolved review threads from a GitHub PR and prints compact structured output.
# Requires: gh (authenticated via `gh auth login` or GH_TOKEN), jq
#
# Usage:
#   get_unresolved_comments.sh              # auto-detects PR for current branch
#   get_unresolved_comments.sh <PR_NUMBER>
#   get_unresolved_comments.sh <PR_URL>

set -euo pipefail

command -v gh  >/dev/null 2>&1 || { echo "gh is not installed or not in PATH" >&2; exit 1; }
command -v jq  >/dev/null 2>&1 || { echo "jq is not installed or not in PATH" >&2; exit 1; }

# Resolve PR number
ARG="${1:-}"
if [[ -z "$ARG" ]]; then
  PR_NUMBER=$(gh pr view --json number --jq '.number' 2>/dev/null) \
    || { echo "No open PR found for current branch" >&2; exit 1; }
elif [[ "$ARG" =~ /pull/([0-9]+) ]]; then
  PR_NUMBER="${BASH_REMATCH[1]}"
elif [[ "$ARG" =~ ^[0-9]+$ ]]; then
  PR_NUMBER="$ARG"
else
  echo "Cannot parse PR reference: $ARG" >&2
  exit 1
fi

# Fetch all review comments (inline) via REST — returns all, we filter unresolved below.
# GitHub considers a thread unresolved when none of its comments is marked as resolved
# (the REST v3 API exposes this via the `in_reply_to_id` structure; GraphQL is cleaner).
# We use GraphQL for reliable thread-level resolution status.
QUERY='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first: 50) {
            nodes {
              databaseId
              author { login }
              body
              createdAt
            }
          }
        }
      }
    }
  }
}
'

# Resolve owner/repo from git remote
REMOTE_URL=$(git remote get-url origin 2>/dev/null) || { echo "No git remote 'origin' found" >&2; exit 1; }
if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
else
  echo "Cannot parse GitHub owner/repo from remote: $REMOTE_URL" >&2
  exit 1
fi

RESULT=$(gh api graphql \
  -f query="$QUERY" \
  -F owner="$OWNER" \
  -F repo="$REPO" \
  -F number="$PR_NUMBER")

jq -r --argjson pr "$PR_NUMBER" '
  .data.repository.pullRequest.reviewThreads.nodes
  | map(select(.isResolved == false and .isOutdated == false))
  | if length == 0 then
      "NO UNRESOLVED REVIEW THREADS"
    else
      "UNRESOLVED REVIEW THREADS (\(length)) on PR #\($pr):",
      "",
      (
        to_entries[]
        | "[\(.key + 1)] thread_id: \(.value.id)",
          "    file:    \(.value.path)\(.value.line | if . then ":\(.)" else "" end)",
          "    author:  \(.value.comments.nodes[0].author.login)",
          "    comment: \"\(.value.comments.nodes[0].body)\"",
          (
            .value.comments.nodes[1:][]
            | "  [reply by \(.author.login)]: \(.body)"
          ),
          ""
      )
    end
' <<< "$RESULT"
