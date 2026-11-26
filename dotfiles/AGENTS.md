# Documentation Principles

- Keep it concise
  - Use the fewest words that preserve the meaning
  - Delete any sentence whose removal does not change the meaning or make the text harder to follow
  - When in doubt, delete
- Write for readers who are not native English speakers
  - Use direct and unambiguous language
  - Avoid idioms and overly poetic expressions
- Use consistent terminology
- Write for the intended audience
  - Ask who the audience is if unclear
  - Omit information the audience already knows
- Keep only content the reader needs to understand, decide, or act
- Explain a rule only when needed for clarity
- State each point once
  - Omit summaries that only repeat earlier content
  - Refer to authoritative sources instead of duplicating their content
- Start directly
  - Omit sentences that announce what the text will explain
- Remove empty emphasis
- Match the tone of existing documentation
  - Use a professional tone if there is none
- Stay within scope
  - Omit adjacent advice and unsolicited next steps.
- Use examples selectively
  - Add them only to resolve a likely misunderstanding
- Review concision at the section level and then the entire document level
  - Prefer a short summary over exhaustive narrative when it preserves the
    decision, contracts, invariants, and necessary exceptions.
  - If a section can be reduced to a few direct bullets without losing meaning,
    use the shorter form.
  - Do not retain a detail only because it is true or relevant to the code.

# Code style

- Stick to the simplest design that works. Don't accumulate fallback, migration, or compatibility code — it causes toil.
- **Comments are a maintenance cost; default to none.** Names, types, and tests carry the meaning. Write a comment only for a non-obvious *why* that code cannot express, and keep it to a line or two.
- Never narrate the change (`previously`, `no longer`, `instead of`, versions, issue/PR numbers). That belongs in the commit message and PR description.
- Rationale lives in the plan or ADR, not inline. At most one short pointer to it, and never the same explanation mirrored in two places.
- A small code change should not need a comment rewrite. If it does, cut the comment down or delete it rather than rewrite it.

# Git protected-branch approvals

- Before committing and pushing, check the current branch with `git branch --show-current`.
- Do not commit changes and push commits to the repository's default branch unless the user asks it.
- In `git topic-{commit,push}` commands, the default branch comes from local `origin/HEAD`, then the remote origin's advertised `HEAD`.
  - If the default branch cannot be determined or HEAD is detached, do not commit or push without asking the user.

## Commit

- On any topic branch, use `git topic-commit`
- On the default branch, use `git commit`; it requires user approval.

## Push commits

- On any topic branch, use `git topic-push`; it pushes only the current branch to its same name on `origin`.
- On the default branch, use `git push`; it requires user approval.
- `git topic-push` accepts an optional `origin` plus safe push flags.
  - Use ordinary `git push` and request approval for another remote, an explicit refspec, deletion, `--all`, `--mirror`, or `--tags`.

# Guide to work on tasks

- Do not run heavy tasks on the main agent
  - The main agent should focus on orchestration of running tasks and subagents
  - Spawn a subagent to work on a non-trivial task
    - Spawn a fresh subagent by default, fork only when necessary
    - Trivial tasks stay on the main agent: finishable in a few tool calls
      with small output, e.g. a quick lookup or a known single-file edit
    - Delegate when a task needs broad exploration, multi-step changes, or
      pulls large output into context (build logs, long diffs, many files)
- Leverage concurrency with subagents when there are multiple independent tasks
  - The main agent is responsible for breaking a large task into smaller ones so that
    subagents can work on them concurrently
