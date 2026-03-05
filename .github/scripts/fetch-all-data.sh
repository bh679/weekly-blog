#!/usr/bin/env bash
# fetch-all-data.sh
# Collects cross-project development activity for the weekly blog.
# Uses GitHub Events API, commit history, merged PRs, and the Chess project board.
# Writes a single JSON file to /tmp/weekly-blog-data.json.
#
# Requires: gh CLI authenticated with broad repo access (GH_TOKEN env var)

set -euo pipefail

OUTPUT="/tmp/weekly-blog-data.json"
SEVEN_DAYS_AGO=$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)
TODAY=$(date -u +%Y-%m-%d)

echo "=== Fetching All-Projects Blog Data ==="
echo "Date range: $SEVEN_DAYS_AGO to now"

# --- 1. GitHub Events for user bh679 ---
echo "Fetching GitHub events..."

# --paginate returns separate JSON arrays per page; merge them with jq -s 'add'
RAW_EVENTS=$(gh api users/bh679/events --paginate 2>/dev/null || echo '[]')
RECENT_EVENTS=$(echo "$RAW_EVENTS" | jq -s 'add // []' | jq --arg since "$SEVEN_DAYS_AGO" '[
  .[] | select(.created_at >= $since) |
  {
    type: .type,
    repo: .repo.name,
    created_at: .created_at,
    payload_action: .payload.action,
    ref: .payload.ref,
    commits: (if .type == "PushEvent" then [.payload.commits[]? | {sha: .sha[0:7], message: .message}] else null end),
    pr_title: .payload.pull_request.title,
    pr_number: .payload.pull_request.number,
    issue_title: .payload.issue.title,
    issue_number: .payload.issue.number
  }
]')
EVENT_COUNT=$(echo "$RECENT_EVENTS" | jq 'length')
echo "Found $EVENT_COUNT events in the last 7 days."

# --- 2. Repos with activity ---
echo "Identifying active repos..."

ACTIVE_REPOS=$(echo "$RECENT_EVENTS" | jq -r '[.[].repo] | unique | .[]')
REPO_COUNT=$(echo "$ACTIVE_REPOS" | grep -c . || echo 0)
echo "Found $REPO_COUNT active repos."

# Per-repo summaries
REPO_SUMMARIES="[]"
while IFS= read -r repo; do
  [ -z "$repo" ] && continue
  echo "  Fetching data for $repo..."

  # Recent commits
  REPO_COMMITS=$(gh api "repos/$repo/commits?since=$SEVEN_DAYS_AGO&per_page=30" --jq '[.[] | {sha: .sha[0:7], message: .commit.message, date: .commit.author.date, author: .commit.author.name}]' 2>/dev/null || echo '[]')

  # Merged PRs
  REPO_PRS=$(gh pr list --repo "$repo" --state merged --json number,title,mergedAt,author --limit 10 2>/dev/null || echo '[]')
  REPO_PRS=$(echo "$REPO_PRS" | jq --arg since "$SEVEN_DAYS_AGO" '[.[] | select(.mergedAt >= $since)]')

  REPO_SUMMARIES=$(echo "$REPO_SUMMARIES" | jq --arg repo "$repo" --argjson commits "$REPO_COMMITS" --argjson prs "$REPO_PRS" '. + [{
    repo: $repo,
    commit_count: ($commits | length),
    commits: $commits,
    prs_merged: $prs,
    pr_count: ($prs | length)
  }]')
done <<< "$ACTIVE_REPOS"

# --- 3. Chess project board ---
echo "Fetching Chess project board..."

CHESS_BOARD=$(gh api graphql -f query='
{
  user(login: "bh679") {
    projectV2(number: 1) {
      items(first: 100) {
        nodes {
          content {
            ... on DraftIssue { title }
            ... on Issue { title }
          }
          fieldValues(first: 20) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
                field { ... on ProjectV2SingleSelectField { name } }
              }
              ... on ProjectV2ItemFieldNumberValue {
                number
                field { ... on ProjectV2Field { name } }
              }
              ... on ProjectV2ItemFieldTextValue {
                text
                field { ... on ProjectV2Field { name } }
              }
            }
          }
        }
      }
    }
  }
}')

CHESS_ITEMS=$(echo "$CHESS_BOARD" | jq '[
  .data.user.projectV2.items.nodes[] |
  {
    title: .content.title,
    status: ([.fieldValues.nodes[] | select(.field.name == "Status") | .name] | first // null),
    priority: ([.fieldValues.nodes[] | select(.field.name == "Priority") | .name] | first // null),
    categories: ([.fieldValues.nodes[] | select(.field.name == "Categories") | .name] | first // null),
    score: ([.fieldValues.nodes[] | select(.field.name == "Score") | .number] | first // null)
  }
]')
CHESS_ITEM_COUNT=$(echo "$CHESS_ITEMS" | jq 'length')
echo "Found $CHESS_ITEM_COUNT Chess project board items."

# --- 4. Merged PRs across all repos ---
echo "Fetching merged PRs across all repos..."

# gh search prs uses --merged for date filter
ALL_MERGED_PRS=$(gh search prs --author bh679 --merged ">=$SEVEN_DAYS_AGO" --json repository,title,number,updatedAt --limit 30 2>/dev/null || echo '[]')
ALL_PR_COUNT=$(echo "$ALL_MERGED_PRS" | jq 'length')
echo "Found $ALL_PR_COUNT merged PRs across all repos."

# --- 5. Previous state ---
echo "Reading previous state..."

if [ -f "state.json" ]; then
  PREVIOUS_STATE=$(cat state.json)
  LAST_RUN=$(echo "$PREVIOUS_STATE" | jq -r '.last_run // "never"')
  echo "Previous state found (last run: $LAST_RUN)"
else
  PREVIOUS_STATE='{"last_run": null, "repos_snapshot": {}, "chess_project_board_snapshot": {"items": []}}'
  echo "No previous state found — first run."
fi

# --- 6. Pending feature context ---
echo "Reading pending-context.json..."

if [ -f "pending-context.json" ]; then
  PENDING_CONTEXT=$(cat pending-context.json)
  PENDING_COUNT=$(echo "$PENDING_CONTEXT" | jq 'length' 2>/dev/null || echo 0)
  echo "Found $PENDING_COUNT pending feature context entries."
else
  PENDING_CONTEXT='[]'
  PENDING_COUNT=0
  echo "No pending-context.json found — skipping."
fi

# --- Compose output ---
echo "Writing output to $OUTPUT..."

jq -n \
  --arg date "$TODAY" \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg period_start "$(date -u -d '7 days ago' +%Y-%m-%d 2>/dev/null || date -u -v-7d +%Y-%m-%d)" \
  --arg period_end "$TODAY" \
  --argjson events "$RECENT_EVENTS" \
  --argjson repo_summaries "$REPO_SUMMARIES" \
  --argjson chess_items "$CHESS_ITEMS" \
  --argjson all_merged_prs "$ALL_MERGED_PRS" \
  --argjson previous_state "$PREVIOUS_STATE" \
  --argjson pending_context "$PENDING_CONTEXT" \
  '{
    generated_at: $generated_at,
    date: $date,
    period: {start: $period_start, end: $period_end},
    github_events: {
      total: ($events | length),
      by_type: ([$events[] | select(.type != null)] | group_by(.type) | map({key: .[0].type, value: length}) | from_entries),
      events: $events
    },
    repos_with_activity: $repo_summaries,
    chess_project_board: {
      items: $chess_items,
      summary: {
        total: ($chess_items | length),
        by_status: ([$chess_items[] | select(.status != null)] | group_by(.status) | map({key: .[0].status, value: length}) | from_entries)
      }
    },
    all_merged_prs: $all_merged_prs,
    previous_state: $previous_state,
    pending_context: $pending_context
  }' > "$OUTPUT"

echo ""
echo "=== Done ==="
echo "Output: $OUTPUT"
echo "Events: $EVENT_COUNT | Repos: $REPO_COUNT | Chess items: $CHESS_ITEM_COUNT | PRs: $ALL_PR_COUNT | Pending context: $PENDING_COUNT"
