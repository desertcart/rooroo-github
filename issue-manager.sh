#!/bin/bash

# GitHub Issue Management Wrapper for Roo Workflow System
# This script provides a simplified interface to manage GitHub issues, issue types, and sub-issues
# Used by the .roomodes AI agents to manage state via GitHub Issues

# Default repository info (can be overridden with --repo flag)
DEFAULT_ORG="<set_org_name>"
DEFAULT_REPO="<set_repo_name>"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/"

# Parse repository flag if provided, otherwise use defaults
parse_repo_flag() {
  local org=$DEFAULT_ORG
  local repo=$DEFAULT_REPO
  
  for i in "$@"; do
    case $i in
      --repo=*)
        local repo_full="${i#*=}"
        if [[ $repo_full == */* ]]; then
          org="${repo_full%%/*}"
          repo="${repo_full#*/}"
        else
          repo="$repo_full"
        fi
        ;;
    esac
  done
  
  echo "$org $repo"
}

# Verify GitHub CLI is installed and authenticated
verify_github_cli() {
  if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI is not installed. Please install it and try again.${NC}"
    exit 1
  fi
  
  if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI not authenticated. Please run 'gh auth login' first.${NC}"
    exit 1
  fi
}

# Verify script exists
verify_script() {
  local script="$1"
  if [[ ! -f "$SCRIPT_DIR/$script" ]]; then
    echo -e "${RED}Error: Script $script not found in $SCRIPT_DIR${NC}"
    exit 1
  fi
  
  if [[ ! -x "$SCRIPT_DIR/$script" ]]; then
    echo -e "${YELLOW}Warning: Script $script is not executable. Attempting to fix...${NC}"
    chmod +x "$SCRIPT_DIR/$script"
  fi
}

# Create a new issue
create_issue() {
  local title=""
  local body=""
  local labels=""

  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --title=*) title="${1#*=}" ;;
      --body=*) body="${1#*=}" ;;
      --body-file=*)
        local body_file="${1#*=}"
        if [[ -f "$body_file" ]]; then
          body=$(<"$body_file")
        else
          echo -e "${RED}Error: Body file not found: $body_file${NC}"
          return 1
        fi
        ;;
      --labels=*) labels="${1#*=}" ;;
      --repo=*) : ;; # already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done

  # Validate required parameters
  if [[ -z "$title" ]]; then
    echo -e "${RED}Error: --title is required${NC}"
    return 1
  fi

  read -r org repo <<< "$(parse_repo_flag "$@")"

  # Build arguments array
  local args=(--title "$title" --repo "$org/$repo")

  if [[ -n "$body" ]]; then
    args+=(--body "$body")
  fi

  if [[ -n "$labels" ]]; then
    args+=(--label "$labels")
  fi

  # Execute the GitHub CLI command
  local result
  if ! result=$(gh issue create "${args[@]}"); then
    echo -e "${RED}Failed to create issue${NC}"
    return 1
  fi

  # Parse and output the created issue number
  local issue_number
  issue_number=$(echo "$result" | sed -n 's|.*/issues/\([0-9]*\).*|\1|p')

  if [[ -n "$issue_number" ]]; then
    echo -e "${GREEN}Created issue #$issue_number${NC}"
    echo "$issue_number"
    return 0
  else
    echo -e "${RED}Failed to parse issue number${NC}"
    return 1
  fi
}

# Add a label to an issue
add_label() {
  local issue_number=""
  local label=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --label=*) label="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  if [[ -z "$label" ]]; then
    echo -e "${RED}Error: --label is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  if gh issue edit "$issue_number" --add-label "$label" --repo "$org/$repo"; then
    echo -e "${GREEN}Added label '$label' to issue #$issue_number${NC}"
    return 0
  else
    echo -e "${RED}Failed to add label '$label' to issue #$issue_number${NC}"
    return 1
  fi
}

# Remove a label from an issue
remove_label() {
  local issue_number=""
  local label=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --label=*) label="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  if [[ -z "$label" ]]; then
    echo -e "${RED}Error: --label is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  if gh issue edit "$issue_number" --remove-label "$label" --repo "$org/$repo"; then
    echo -e "${GREEN}Removed label '$label' from issue #$issue_number${NC}"
    return 0
  else
    echo -e "${RED}Failed to remove label '$label' from issue #$issue_number${NC}"
    return 1
  fi
}

# Add a comment to an issue
add_comment() {
  local issue_number=""
  local body=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --body=*) body="${1#*=}" ;;
      --body-file=*)
        local body_file="${1#*=}"
        if [[ -f "$body_file" ]]; then
          body=$(cat "$body_file")
        else
          echo -e "${RED}Error: Body file not found: $body_file${NC}"
          return 1
        fi
        ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  if [[ -z "$body" ]]; then
    echo -e "${RED}Error: --body or --body-file is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  if gh issue comment "$issue_number" --body "$body" --repo "$org/$repo"; then
    echo -e "${GREEN}Added comment to issue #$issue_number${NC}"
    return 0
  else
    echo -e "${RED}Failed to add comment to issue #$issue_number${NC}"
    return 1
  fi
}

# Close an issue
close_issue() {
  local issue_number=""
  local comment=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --comment=*) comment="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  local cmd="gh issue close $issue_number --repo $org/$repo"
  
  if [[ -n "$comment" ]]; then
    cmd+=" --comment \"$comment\""
  fi
  
  if eval "$cmd"; then
    echo -e "${GREEN}Closed issue #$issue_number${NC}"
    return 0
  else
    echo -e "${RED}Failed to close issue #$issue_number${NC}"
    return 1
  fi
}

# Reopen an issue
reopen_issue() {
  local issue_number=""
  local comment=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --comment=*) comment="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  local cmd="gh issue reopen $issue_number --repo $org/$repo"
  
  if [[ -n "$comment" ]]; then
    cmd+=" --comment \"$comment\""
  fi
  
  if eval "$cmd"; then
    echo -e "${GREEN}Reopened issue #$issue_number${NC}"
    return 0
  else
    echo -e "${RED}Failed to reopen issue #$issue_number${NC}"
    return 1
  fi
}

# Get issue details
get_issue() {
  local issue_number=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  gh issue view "$issue_number" --json number,title,body,state,labels,assignees,comments --repo "$org/$repo"
  return $?
}

# List issues with specific labels
list_issues() {
  local labels=""
  local state="open"
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --labels=*) labels="${1#*=}" ;;
      --state=*) state="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  local cmd="gh issue list --repo $org/$repo --state $state"
  
  if [[ -n "$labels" ]]; then
    cmd+=" --label \"$labels\""
  fi
  
  eval "$cmd"
  return $?
}

# Update issue status via labels
update_issue_status() {
  local issue_number=""
  local status=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --status=*) status="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  if [[ -z "$status" ]]; then
    echo -e "${RED}Error: --status is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Get current status labels
  local current_labels
  current_labels=$(gh issue view "$issue_number" --json labels --repo "$org/$repo" | 
    jq -r '.labels[] | select(.name | startswith("status:")) | .name')
  
  # Remove current status labels and add new one
  if [[ -n "$current_labels" ]]; then
    while read -r label; do
      gh issue edit "$issue_number" --remove-label "$label" --repo "$org/$repo" > /dev/null
    done <<< "$current_labels"
  fi
  
  # Add new status label
  if gh issue edit "$issue_number" --add-label "status:$status" --repo "$org/$repo"; then
    echo -e "${GREEN}Updated issue #$issue_number status to '$status'${NC}"
    return 0
  else
    echo -e "${RED}Failed to update issue #$issue_number status to '$status'${NC}"
    return 1
  fi
}

# Create a subissue relationship (parent-child)
add_subissue() {
  local parent_issue=""
  local child_issue=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --parent=*) parent_issue="${1#*=}" ;;
      --child=*) child_issue="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$parent_issue" ]]; then
    echo -e "${RED}Error: --parent is required${NC}"
    return 1
  fi
  
  if [[ -z "$child_issue" ]]; then
    echo -e "${RED}Error: --child is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "add-sub-issue-to-issue.sh"
  
  if "$SCRIPT_DIR/add-sub-issue-to-issue.sh" "$org" "$repo" "$parent_issue" "$child_issue"; then
    echo -e "${GREEN}Added issue #$child_issue as a subissue to #$parent_issue${NC}"
    return 0
  else
    echo -e "${RED}Failed to add subissue relationship${NC}"
    return 1
  fi
}

# Remove a subissue relationship
remove_subissue() {
  local parent_issue=""
  local child_issue=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --parent=*) parent_issue="${1#*=}" ;;
      --child=*) child_issue="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$parent_issue" ]]; then
    echo -e "${RED}Error: --parent is required${NC}"
    return 1
  fi
  
  if [[ -z "$child_issue" ]]; then
    echo -e "${RED}Error: --child is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "remove-sub-issue-from-issue.sh"
  
  if "$SCRIPT_DIR/remove-sub-issue-from-issue.sh" "$org" "$repo" "$parent_issue" "$child_issue"; then
    echo -e "${GREEN}Removed issue #$child_issue as a subissue from #$parent_issue${NC}"
    return 0
  else
    echo -e "${RED}Failed to remove subissue relationship${NC}"
    return 1
  fi
}

# Get subissues of an issue
get_subissues() {
  local parent_issue=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --parent=*) parent_issue="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$parent_issue" ]]; then
    echo -e "${RED}Error: --parent is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "get-sub-issues-of-issue.sh"
  
  "$SCRIPT_DIR/get-sub-issues-of-issue.sh" "$org" "$repo" "$parent_issue" | jq '.'
  return ${PIPESTATUS[0]}
}

# Get subissues summary of an issue
get_subissues_summary() {
  local parent_issue=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --parent=*) parent_issue="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$parent_issue" ]]; then
    echo -e "${RED}Error: --parent is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "get-sub-issues-summary-of-issue.sh"
  
  "$SCRIPT_DIR/get-sub-issues-summary-of-issue.sh" "$org" "$repo" "$parent_issue" | jq '.'
  return ${PIPESTATUS[0]}
}

# Get parent issue of an issue
get_parent_issue() {
  local child_issue=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --child=*) child_issue="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$child_issue" ]]; then
    echo -e "${RED}Error: --child is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "get-parent-issue-of-issue.sh"
  
  "$SCRIPT_DIR/get-parent-issue-of-issue.sh" "$org" "$repo" "$child_issue" | jq '.'
  return ${PIPESTATUS[0]}
}

# Set issue type
set_issue_type() {
  local issue_number=""
  local type=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --type=*) type="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  if [[ -z "$type" ]]; then
    echo -e "${RED}Error: --type is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "update-issue-issue-type.sh"
  
  if "$SCRIPT_DIR/update-issue-issue-type.sh" "$org" "$repo" "$issue_number" "$type"; then
    echo -e "${GREEN}Set issue #$issue_number type to '$type'${NC}"
    return 0
  else
    echo -e "${RED}Failed to set issue type${NC}"
    return 1
  fi
}

# Get issue type
get_issue_type() {
  local issue_number=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "get-issue-type-of-issue.sh"
  
  "$SCRIPT_DIR/get-issue-type-of-issue.sh" "$org" "$repo" "$issue_number" | jq '.'
  return ${PIPESTATUS[0]}
}

# Remove issue type
remove_issue_type() {
  local issue_number=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --issue=*) issue_number="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$issue_number" ]]; then
    echo -e "${RED}Error: --issue is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "remove-issue-issue-type.sh"
  
  if "$SCRIPT_DIR/remove-issue-issue-type.sh" "$org" "$repo" "$issue_number"; then
    echo -e "${GREEN}Removed issue type from issue #$issue_number${NC}"
    return 0
  else
    echo -e "${RED}Failed to remove issue type${NC}"
    return 1
  fi
}

# Create a new branch
create_branch() {
  local branch_name=""
  local base_branch="main"
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --name=*) branch_name="${1#*=}" ;;
      --base=*) base_branch="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$branch_name" ]]; then
    echo -e "${RED}Error: --name is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  if gh api --method POST repos/$org/$repo/git/refs \
     -f ref="refs/heads/$branch_name" \
     -f sha="$(gh api repos/$org/$repo/git/refs/heads/$base_branch --jq '.object.sha')"; then
    echo -e "${GREEN}Created branch '$branch_name' from '$base_branch'${NC}"
    return 0
  else
    echo -e "${RED}Failed to create branch '$branch_name'${NC}"
    return 1
  fi
}

# Create a new PR
create_pr() {
  local title=""
  local body=""
  local head=""
  local base="main"
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --title=*) title="${1#*=}" ;;
      --body=*) body="${1#*=}" ;;
      --body-file=*)
        local body_file="${1#*=}"
        if [[ -f "$body_file" ]]; then
          body=$(cat "$body_file")
        else
          echo -e "${RED}Error: Body file not found: $body_file${NC}"
          return 1
        fi
        ;;
      --head=*) head="${1#*=}" ;;
      --base=*) base="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$title" ]]; then
    echo -e "${RED}Error: --title is required${NC}"
    return 1
  fi
  
  if [[ -z "$head" ]]; then
    echo -e "${RED}Error: --head is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  local cmd="gh pr create --title \"$title\" --head \"$head\" --base \"$base\" --repo $org/$repo"
  
  if [[ -n "$body" ]]; then
    cmd+=" --body \"$body\""
  fi
  
  if eval "$cmd"; then
    echo -e "${GREEN}Created PR from '$head' to '$base'${NC}"
    return 0
  else
    echo -e "${RED}Failed to create PR${NC}"
    return 1
  fi
}

# Get PR review comments
get_pr_comments() {
  local pr_number=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --pr=*) pr_number="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$pr_number" ]]; then
    echo -e "${RED}Error: --pr is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "get-pr-comments.sh"
  
  "$SCRIPT_DIR/get-pr-comments.sh" "$org" "$repo" "$pr_number" | jq '.'
  return ${PIPESTATUS[0]}
}

# Reply to a PR review comment
reply_to_pr_comment() {
  local comment_id=""
  local body=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --comment=*) comment_id="${1#*=}" ;;
      --body=*) body="${1#*=}" ;;
      --body-file=*)
        local body_file="${1#*=}"
        if [[ -f "$body_file" ]]; then
          body=$(cat "$body_file")
        else
          echo -e "${RED}Error: Body file not found: $body_file${NC}"
          return 1
        fi
        ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$comment_id" ]]; then
    echo -e "${RED}Error: --comment is required${NC}"
    return 1
  fi
  
  if [[ -z "$body" ]]; then
    echo -e "${RED}Error: --body or --body-file is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "reply-to-pr-comment.sh"
  
  "$SCRIPT_DIR/reply-to-pr-comment.sh" "$org" "$repo" "$comment_id" "$body"
  return $?
}

# Resolve a PR review comment
resolve_pr_comment() {
  local comment_id=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --comment=*) comment_id="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$comment_id" ]]; then
    echo -e "${RED}Error: --comment is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "resolve-pr-comment.sh"
  
  "$SCRIPT_DIR/resolve-pr-comment.sh" "$org" "$repo" "$comment_id"
  return $?
}

# Get details of a specific pull request
get_pull_request() {
  local pr_number=""
  
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --pr=*) pr_number="${1#*=}" ;;
      --repo=*) : ;; # Already handled by parse_repo_flag
      *) echo -e "${RED}Unknown parameter: $1${NC}" >&2; return 1 ;;
    esac
    shift
  done
  
  # Validate required parameters
  if [[ -z "$pr_number" ]]; then
    echo -e "${RED}Error: --pr is required${NC}"
    return 1
  fi
  
  read -r org repo <<< "$(parse_repo_flag "$@")"
  
  # Verify script exists
  verify_script "get-pull-request.sh"
  
  "$SCRIPT_DIR/get-pull-request.sh" "$org" "$repo" "$pr_number" | jq '.'
  return ${PIPESTATUS[0]}
}


# Main function to handle command dispatch
main() {
  # Verify GitHub CLI
  verify_github_cli
  
  # Check if a subcommand was provided
  if [ $# -lt 1 ]; then
    echo "Usage: $0 <command> [options]"
    echo "Commands:"
    echo "  create-issue              Create a new issue"
    echo "  add-label                 Add a label to an issue"
    echo "  remove-label              Remove a label from an issue"
    echo "  add-comment               Add a comment to an issue"
    echo "  close-issue               Close an issue"
    echo "  reopen-issue              Reopen an issue"
    echo "  get-issue                 Get issue details"
    echo "  list-issues               List issues with specific labels"
    echo "  update-issue-status       Update issue status via labels"
    echo "  add-subissue              Create a subissue relationship"
    echo "  remove-subissue           Remove a subissue relationship"
    echo "  get-subissues             Get subissues of an issue"
    echo "  get-subissues-summary     Get subissues summary of an issue"
    echo "  get-parent-issue          Get parent issue of an issue"
    echo "  set-issue-type            Set issue type"
    echo "  get-issue-type            Get issue type"
    echo "  remove-issue-type         Remove issue type"
    echo "  create-branch             Create a new branch"
    echo "  create-pr                 Create a new PR"
    exit 1
  fi
  
  # Get the subcommand
  local cmd="$1"
  shift
  
  # Dispatch to the appropriate function
  case "$cmd" in
    create-issue) create_issue "$@" ;;
    add-label) add_label "$@" ;;
    remove-label) remove_label "$@" ;;
    add-comment) add_comment "$@" ;;
    close-issue) close_issue "$@" ;;
    reopen-issue) reopen_issue "$@" ;;
    get-issue) get_issue "$@" ;;
    list-issues) list_issues "$@" ;;
    update-issue-status) update_issue_status "$@" ;;
    add-subissue) add_subissue "$@" ;;
    remove-subissue) remove_subissue "$@" ;;
    get-subissues) get_subissues "$@" ;;
    get-subissues-summary) get_subissues_summary "$@" ;;
    get-parent-issue) get_parent_issue "$@" ;;
    set-issue-type) set_issue_type "$@" ;;
    get-issue-type) get_issue_type "$@" ;;
    remove-issue-type) remove_issue_type "$@" ;;
    create-branch) create_branch "$@" ;;
    create-pr) create_pr "$@" ;;
    get-pr-comments) get_pr_comments "$@" ;;
    reply-to-pr-comment) reply_to_pr_comment "$@" ;;
    resolve-pr-comment) resolve_pr_comment "$@" ;;
    get-pull-request) get_pull_request "$@" ;;
    *) echo -e "${RED}Unknown command: $cmd${NC}" >&2; exit 1 ;;
  esac
}

# Run main function with all arguments
main "$@"
