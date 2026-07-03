# Global Instructions

This is the tool-neutral personal instruction file. Codex, Claude Code, OpenCode,
and any generic agent shim should link here instead of treating one tool's config
directory as the source of truth.

Repository-level instructions take precedence over this file. Keep company,
project, and repository-specific rules in the nearest `AGENTS.md`, `CLAUDE.md`,
or project config file, not in this global file.

## Concision

Concise by default; never at the expense of correctness, clarity, or recoverability.
When clarity and brevity conflict, prefer clarity.

- Ultra-concise: commit messages, PR descriptions, simple factual answers.
- Moderate: status updates, test summaries, small implementation decisions.
- Detailed/structured: debugging, migrations, root-cause analysis, trade-offs, state recovery, cross-PR coordination.
- Simple + layman terms: docs, presentations, anything for a broad audience.

Always: no AI attribution in commits, code, or comments. Commit as the user; no
AI-involvement mentions anywhere.

## Language

Always respond in English, regardless of the user's message language, unless
explicitly told "respond in <language>". Spanish input is not permission to answer
in Spanish. If you slip, correct immediately.

## Checkpoints & State Recovery

Use the personal `continuity` tool for long-running work across Codex, Claude Code,
and OpenCode. Prefer `~/.local/bin/continuity` when an absolute path is needed;
otherwise `continuity` is fine when it is on `PATH`.

- On "where are we", "current state", "resume", or similar: identify the task ID
  from the prompt, checkpoint filename, branch, issue, or ticket. If no task ID can
  be inferred safely, ask for it. Then run `continuity resume --task-id <TASK-ID>`
  before relying on markdown projections.
- On "checkpoint", "dump context", "save progress", or similar: write through
  `continuity checkpoint` and reconcile the canon. Do not manually edit exported
  markdown checkpoint files as the authority.
- Prefer a real tracker/ticket ID when one is visible; otherwise use a short,
  descriptive kebab-case task ID. Do not invent a tracker ID.
- If `continuity` is unavailable, say so and provide a concise manual handoff
  instead of pretending a checkpoint was saved.

## Output Reliability

If a response degrades or looks malformed: stop, acknowledge corruption, give a
clean recovery answer. Do not continue the broken stream.

## GitHub

- Use `gh` CLI primarily for repository and pull request inspection (`gh repo`,
  `gh pr`, `gh issue`, `gh api`, `gh search`) because it exposes GitHub-native
  primitives that are more reliable than reconstructing those views from local
  checkout text.
- Use local `rg` for code/content search within an already-selected checkout, but
  do not treat `rg` as the default harness for GitHub repo, PR, issue, review, or
  branch state.

## POC & Worktree Hygiene

- POCs, spikes, and destructive experiments: use a fresh worktree from the target
  remote branch after verifying branch and commit. Keep discovery clones read-only;
  implementation edits belong in a separate worktree.
- When done: remove worktree and branch, clean external resources, and verify with
  the relevant postconditions (`git worktree list`, `git status --short`, or the
  system-specific cleanup command).
- For external-resource POCs, define the cleanup invariant and label resources
  before creating them.

## Plans

- End every plan with unresolved questions, if any, in ultra-concise form.
- In plan mode: optimize for decision quality, not brevity. Surface assumptions,
  risks, blockers, open questions, validation targets, fallback paths, and stop
  triggers. Make the plan detailed enough to execute without guessing.

## Code Quality Bias

- Prefer idiomatic code for the language/framework in use; the codebase's
  convention beats the textbook idiom.
- Read neighboring files first.
- Cohesion: each helper/type has one reason to exist and lives near its primary
  caller unless broadly reused.
- Use SOLID/DRY pragmatically: remove duplication when it hides behavior, risks
  drift, or complicates tests. Do not introduce speculative abstractions.
- Prefer readable, testable flow over cleverness. Formatters own layout.

### While Implementing

- Before: identify which layer owns the behavior; put logic in the narrowest
  cohesive location.
- During: one responsibility per function/type; explicit data flow over hidden
  coupling/global state.
- Before declaring done: re-read the diff for DRY/SOLID/cohesion/decoupling issues
  and fix them even if tests pass. Call out intentional residual risks.

### Layering Rule

Lower-level packages never depend on higher-level workflow concerns. If a change
crosses layers, stop and refactor before finalizing.

### Idiomatic Java (17+, Spring Boot)

- Public API evolution: never add required params to existing public constructors
  or methods. Use delegating overloads; old paths should behave the same.
- Optionality: `Optional` only as return type. Optional collaborators via overloads
  and nullable fields; use a builder only when the type already telescopes badly and
  an API change is in scope.
- Exceptions: config/startup errors fail fast with an actionable message naming the
  offending key/service and the fix. Keep the cause.
- Language level: use pattern-matching `instanceof`, switch expressions, records,
  and text blocks where the baseline allows. Keep `@ConfigurationProperties`
  binding classes mutable when setter binding is the convention.
- Spring: constructor injection only. For `@Configuration`, prefer parameter
  injection over direct `@Bean` calls when dependencies matter. Library-overridable
  beans should use `@ConditionalOnMissingBean`. Avoid publishing host-global bean
  types such as raw `ObjectMapper` from library autoconfigs.
- Streams vs loops: streams for linear map/filter/collect; loops for early exit,
  checked exceptions, and index logic.
- Concurrency: immutability first; `ConcurrentHashMap.computeIfAbsent` for caches.
- Tests: JUnit 5 + AssertJ; names state behavior. Shared test utils only at the
  third consumer.

### Idiomatic Go

- Accept interfaces, return structs; define interfaces at the consumer boundary,
  usually with 1-3 methods.
- Errors: `fmt.Errorf("...: %w", err)` adding context per layer; sentinels with
  `errors.Is/As`; lowercase messages, no trailing punctuation.
- API shape: useful zero values; config struct or functional options instead of
  boolean/positional telescoping.
- `ctx context.Context` is the first param and is never stored in structs.
- Goroutines: starter owns termination; tie lifetime to context. Only the sender
  closes a channel.
- Packages: short lowercase names; no `util`/`common` dumping grounds.
- Tests: table-driven, named cases, `t.Helper()`; stdlib first, testify only if
  already in the repo.

## CLI Change Review Gate

For any CLI command, flag, or output change: run representative success, warning,
and error commands; inspect exact human output; verify it names the correct target;
keep human output compact, full detail in `--json`; keep help text and docs in sync.

## Reviewer Feedback

- Treat review comments as findings to analyze, not patches to copy.
- Identify the underlying bug, affected behavior, and existing pattern before
  implementing a suggestion.
- If 2+ comments hit the same function, stop patching incrementally and re-derive
  the invariant.
- When a reviewer finds a real bug, ask what invariant broke, where else that class
  of bug exists, whether the fix needs a flow refactor, and which tests prove it.
- For destructive/cleanup commands, define the safety invariant first. Design
  mutations as: parse -> validated plan -> fail-before-mutate -> apply -> validate
  postconditions.
- Before pushing review fixes, do a local reviewer-mindset pass for duplicate keys,
  prefix collisions, composed values, unsupported formats, fail-after-mutate,
  nondeterminism, stale docs, and missing tests.

## Agents & Skills

- Use specialized agents proactively when available, with the cheapest capable
  model.
- Installed or generated skill copies under tool config directories are not the
  source of truth unless the local project explicitly says they are. Prefer changing
  the source repository/package, then update installed copies through that tool's
  normal install/update flow.
- If a session has stale skill content, say so and use the source repo as authority
  when it is available.

## Model Selection (Cost/ROI)

Model cost matters. Default to a strong general model; escalate only when the task
needs it.

Suggest Opus-level reasoning and surface it inline before continuing when:
- 5+ tool calls have not resolved the issue.
- Planning spans multiple systems or meaningful trade-offs.
- You catch yourself writing "it depends", "could be X or Y", "unclear", or "not
  sure".
- Analysis spans 2+ repositories.
- Architecture decisions have no clear right answer.

Use a cheaper/faster model for clear execution plans, exact edits, build/test
sequences, grep/search, and mechanical changes.

Subagent routing:
- Explore/search -> cheap/fast model.
- Plan/review/implementation -> strong general model.
- Deep ambiguous reasoning -> strongest available model.

After a long session or 2-3 major tasks, suggest checkpointing and starting fresh.

## Canon Checkpoint Protocol

Long-running tasks use the personal Agent Continuity tool. The database-backed
canon is the source of truth; markdown files are exported compatibility projections.

- Canon: current truth, overwritten, <=1 page, loaded first and in full on resume.
  Sections: SOURCE-OF-TRUTH, CURRENT-TRUTH, DECISIONS, REJECTED, NEXT-ACTION, plus
  a `last-reconciled` header.
- Journal: append-only history.

Rules:
1. ORIENT: run `continuity resume --task-id <TASK-ID>` first and treat that
   database result as authority. Read markdown projections only for detail.
2. CHECKPOINT: append journal and rewrite/reconcile canon through `continuity
   checkpoint` and `continuity reconcile`. Never edit markdown checkpoint files as
   the authority.
3. SUBAGENTS: hand the canon path in the spawn prompt; the subagent returns a
   canon delta; the parent reconciles.
