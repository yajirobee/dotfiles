---
name: pr-review-fix-loop
description: Inspect unresolved GitHub PR review threads, validate and fix findings, verify and publish authorized changes, request a fresh Codex review, and repeat. Use for iterative review/fix cycles on an existing pull request, not for an ordinary self-review without PR comments.
---

# PR Review Fix Loop

Drive an existing pull request from unresolved review findings toward a verified, reviewable state. Treat each comment as a
claim to investigate, not an instruction that is automatically correct.

## Establish scope and authority

1. Read repository instructions and inspect the branch and worktree before changing files. Preserve unrelated user changes.
2. Identify the pull request for the current branch and record its head commit before evaluating comments.
3. Determine the authorized boundary from the conversation:
   - A request to check, inspect, or review findings authorizes read-only investigation and reporting.
   - A request to fix findings authorizes local edits and proportionate verification.
   - Commit, push, review replies, thread resolution, and a new review request require explicit authorization. A later
     `continue` authorizes these only when the preceding handoff clearly named them as the pending actions.
   - Repeated refresh or waiting for new reviews requires an explicit terminal request such as `iterate until clean`,
     `babysit`, or `do not stop`.
4. Never force-push, rewrite history, discard worktree changes, or resolve a thread before its disposition is supported by
   evidence on the PR.

## Get the actionable review set

From the repository root, run:

```bash
python3 <skill-directory>/scripts/list_unresolved_threads.py
```

Pass `--pr NUMBER_OR_URL` when the current branch does not identify the intended pull request. The script is read-only,
derives the repository from the selected pull request, paginates threads and their comments, and returns a head-consistent
snapshot. If the head changes while it is collecting the snapshot, rerun it before evaluating findings.

To check whether the latest head has a completed Codex review, pipe the corresponding `gh pr view` JSON to
`scripts/pr_review_status.py`:

```bash
gh pr view <PR_NUMBER_OR_URL> --json headRefOid,reviews,comments \
  | python3 <skill-directory>/scripts/pr_review_status.py --head <HEAD_SHA>
```

Ignore already resolved threads. Do not assume an unresolved thread is current: compare its path and context with the recorded
PR head, and refresh if the head changes during investigation.

## Evaluate and fix

For each unresolved thread:

1. Reproduce the stated failure when practical. Otherwise establish it from the changed code, related code, tests, and the
   repository's canonical design documents.
2. Classify it as valid, already fixed, stale, or unsupported. Explain unsupported findings rather than making speculative
   changes.
3. For valid findings, implement the smallest cohesive fix that preserves safety invariants and existing behavior outside the
   finding. Update canonical documentation only when behavior or contract changes.
4. Add or update a regression test when the finding changes testable behavior and the repository has an appropriate test
   layer. For documentation-only, mechanical, or otherwise non-testable changes, record the proportionate verification used.
5. Review the affected invariant as a family rather than stopping at the reported input:
   - Check the relevant boundaries, equivalent inputs, related entry points, and failure paths.
   - Confirm affected code, tests, schemas, documentation, and consumers agree where those layers exist.
   Turn recurring dimensions into table-driven tests or subtests when that makes omissions visible.
6. Before publishing, audit the complete behavior affected by the fix, not only the commented lines. Apply repository safety
   principles that are relevant to the change and record durable coverage in tests where practical. When a finding concerns
   structured-data validation, normalization, external formats, publication, or durability, read and apply
   [references/contract-hardening.md](references/contract-hardening.md).
7. Run the narrow tests first, then the repository's full relevant suite, lint/format checks, documentation checks, and
   `git diff --check`. Inspect the final diff for unrelated changes.

If tests fail for a reason introduced by the fix, continue locally until fixed. Stop and report evidence when completion needs
a product decision, additional authority, unavailable credentials, or an external-state change.

## Publish an authorized fix

When commit and PR mutations are authorized:

1. Re-fetch unresolved threads and confirm the target is still unresolved and the PR head has not unexpectedly changed.
2. Commit only the verified cohesive change. Keep behavior-changing fixes separate from optional refactoring.
3. Push without force.
4. Reply in the language and style required by repository instructions. State the fixing commit, the behavior now enforced,
   and the verification result. Do not claim tests that were not run.
5. Resolve only the threads addressed by the pushed commit or a well-supported explanation.
6. If the push changed the remote head, add one top-level PR comment with the exact body `@codex review`, after replies and
   resolutions for the previous review batch:

   ```bash
   gh pr comment <PR_NUMBER_OR_URL> --body '@codex review'
   ```

   Request at most once for each newly pushed head. Do not request another review after an `Everything up-to-date` push or a
   retry with no new commits. If a prior request may have succeeded despite an ambiguous client response, inspect recent
   top-level PR comments and prefer skipping a duplicate.
7. Verify the remote head, resolution state, review-request comment, and local worktree after the mutations.

## Iterate and stop

After requesting a review, refresh once for new unresolved threads. The review may be asynchronous, so absence of an immediate
new thread does not prove the new head was reviewed. Continue waiting and refreshing only when the user authorized an iterative
terminal outcome. Otherwise report that review was requested and stop at that authorization boundary.

For an iterative terminal outcome, declare success only after GitHub shows a completed Codex review associated with the latest
head and submitted after the review request, that review has no unresolved actionable threads, and required checks pass. An
empty thread refresh while that evidence is absent means the review is still pending or its completion is unverified, not that
the loop is clean. Stop with a blocker when safe progress requires user input or external change. Do not busy-poll indefinitely;
wait or monitor only when explicitly requested, and surface new comments before modifying a materially different area.
