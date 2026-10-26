---
name: implement
description: Implement a defined task with isolated development, meaningful tests, and verified commits when the user invokes /implement.
argument-hint: "<task>"
disable-model-invocation: true
---

# Implement

Implement $ARGUMENTS. If no arguments are supplied, use the clearly established
task from the conversation; ask for the task only when it is unclear.

Keep the main session available for questions, decisions, and review. Delegate
implementation to background agents with concrete assignments and these workflow
requirements. Keep orchestration in the main session rather than asking workers
to invoke this skill recursively. If background execution is unavailable,
explain the limitation and ask whether to proceed in the foreground.

- Read the repository instructions and inspect the working tree. Create an
  isolated Git worktree from the appropriate base without disturbing unrelated
  changes. Give workers clear ownership of the files they change.
- For changed behavior, use red/green development: demonstrate the intended
  behavior with a failing test, then implement the change and verify it passes.
  Choose unit tests that exercise observable behavior. Add property-based tests
  for meaningful invariants and integration tests for relevant boundaries; do
  not require every test type for every change.
- Run the repository's relevant static analysis and required checks. Investigate
  failures and distinguish failures introduced by the change from existing ones.
- Make regular, coherent commits that keep the task reviewable. Preserve the
  user's unrelated work. Push, open pull requests, merge, or publish only within
  the authorization provided by the user's task.
- Review the resulting diff and verification evidence. Report what changed,
  which checks passed, and any remaining limitations or decisions.
