# GitHub Usage Rules for RooModes Agents

This document outlines how the RooModes AI agents should interact with GitHub issues to maintain state and coordinate workflows.

## Overview

Instead of using local state files (`project_overview.json` and `.state/tasks/*.json`), the agents now use GitHub issues to track tasks, their status, dependencies, and execution details.

## Issue Manager Script Usage

All GitHub operations should be performed through the provided `issue-manager.sh` script. The script should be available in the current directory or referenced with the proper path.

### Common Script Usage Patterns

```bash
# Create a new issue
./issue-manager.sh create-issue --title="Title here" --body="Description here" --labels="label1,label2"

# Update issue status
./issue-manager.sh update-issue-status --issue=123 --status="Running"

# Set issue type
./issue-manager.sh set-issue-type --issue=123 --type="feature"

# Create parent-child relationship (subissue)
./issue-manager.sh add-subissue --parent=100 --child=101

# Get issue details
./issue-manager.sh get-issue --issue=123

# Get subissues of a parent issue
./issue-manager.sh get-subissues --parent=100
```

### Multi-line Comments (Important)

For multi-line comments or issue bodies, use a heredoc format to prevent shell interpretation issues:

```bash
./issue-manager.sh create-issue --title="Task: Implement Feature X" --body="$(cat <<'EOF'
# Task Description
Implement Feature X according to the specs.

## Acceptance Criteria
- Criterion 1
- Criterion 2 

## References
- path/to/file.rb
EOF
)" --labels="status:Pending"
```

### Repository Override (Optional)

If needed, specify the repository with `--repo=owner/repo`:

```bash
./issue-manager.sh create-issue --title="Title" --body="Body" --repo="username/repo"
```

## State Management Schema

### Issue Structure

1. **Main Project Issue**
   - Acts as the parent/container for all task issues
   - Contains high-level description and project overview
   - Linked to all task issues as sub-issues

2. **Task Issues**
   - Each represents a single task (previously a `.state/tasks/{taskId}.json` file)
   - Linked to main issue as sub-issues
   - Contains full task details in the body
   - Status and type tracked via labels

### Issue Body Structure

```markdown
# Task Description
[Detailed description of the task]

## Acceptance Criteria
- [Criterion 1]
- [Criterion 2]
- ...

## References
- [File/path references]
- [Other references]

## Dependencies
- #[Issue Number] ([Brief description])
```

### Labels for Status and Type

**Status Labels** (prefixed with `status:`):
- `status:Pending`
- `status:Running`
- `status:Implemented`
- `status:Done`
- `status:Error`
- `status:Blocked`
- `status:Blocked-Debug`
- `status:Needs Review`
- `status:Failed`
- `status:Validated`

**Type Labels** (prefixed with `type:`):
- `type:feature`
- `type:refactor`
- `type:chore`
- `type:bugfix`
- `type:tech-design`
- `type:ui-design`
- `type:ux-design`
- `type:validation`
- `type:test-execution`
- `type:documentation-init`
- `type:documentation-update`
- `type:documentation-specific`

## Agent Workflows

### Strategic Planner

1. Creates main project issue
2. Creates task issues for each identified task
3. Sets appropriate type and status labels
4. Establishes parent-child relationships
5. Documents dependencies in issue bodies

### Workflow Coordinator

1. Monitors issues via their status labels
2. Delegates tasks to appropriate specialists based on type labels
3. Updates status labels as tasks progress
4. Manages built-in mode delegation and completion verification
5. Handles testing/validation workflows

### Specialist Agents

1. Receive task (issue number) via payloads
2. Get issue details via `get-issue`
3. Update status to "Running"
4. Perform their specialized work
5. Add detailed comments documenting work performed
6. Update status to "Done" or appropriate status on completion

## Dependencies and Relationships

1. **Task Dependencies**: Referenced in the issue body using `#[issue-number]` format
2. **Parent-Child Relationships**: Established using `add-subissue` command
3. **Related Issues**: Referenced in comments and the issue body

## Error Handling

1. When an error occurs, update issue status to "Error"
2. Add a detailed comment explaining the error
3. For debugging assistance, use "Blocked-Debug" status and add a comment

## Progress Tracking

Use issue comments to provide progress updates and important information during task execution. This maintains a history of work and decisions that would otherwise be lost when simply updating issue status.
