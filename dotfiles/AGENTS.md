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

# Git protected-branch approvals

Before committing, check the current branch with `git branch --show-current`.

- On the repository's default branch, use `git commit`; it requires user approval.
- On any topic branch, use `git topic-commit`; it is pre-approved and verifies the branch again before committing.
- The default branch comes from repository-local `codex.defaultBranch`, then local `origin/HEAD`, then the remote origin's advertised `HEAD`.
- If the default branch cannot be determined or HEAD is detached, do not commit without asking the user.

Before pushing, check the current branch with `git branch --show-current`.

- On the repository's default branch, use `git push`; it requires user approval.
- On any topic branch, use `git topic-push`; it is pre-approved and pushes only the current branch to its same name on `origin`.
- `git topic-push` accepts an optional `origin` plus safe push flags. Use ordinary `git push` and request approval for another remote, an explicit refspec, deletion, `--all`, `--mirror`, or `--tags`.
- If the default branch cannot be determined or HEAD is detached, do not push without asking the user.
