---
name: adversarial-review
description: >
  Adversarial code review of changes to JDInstaller: working tree, staged diff,
  branch, commit range, or PR. Hunts for non-idempotent tasks, roles that
  break when disabled or run alone, unverified downloads and signing keys,
  over-broad privilege, secrets in a public repository, group_vars drift, and
  README contract drift in this Ansible Ubuntu-setup playbook, then reports
  ranked findings. Use when the user asks to review changes, a diff, PR,
  branch, or commit; check work before committing; assess merge readiness; or
  poke holes in an implementation.
---

# Adversarial Review - JDInstaller

Assume the change is wrong until proven right: it breaks a second run, a
disabled role, a fresh machine, or a documented contract. Find the concrete
host state, variable value, or tag selection where it fails. Do not praise or
restyle the change. A review with no findings is credible only after active
attempts to break the changed behavior.

This skill routes to the project's authorities rather than replacing them: `AGENTS.md` and the
README own the rules.

## Scope

When invoked directly: review the scope the user gives (`gh pr view <n>` for intent, then `gh pr
diff <n>`); with none, the uncommitted work (`git diff HEAD` plus untracked files, which no diff
shows); on a clean tree, `git diff master...HEAD`. Never review from memory or only from the
user's description of the change.

Read the stated intent (`git log --oneline` for the range, any linked issue or PR body): code
that works but does something other than the stated intent is a finding. Read every changed file
with enough surrounding context to understand its contracts. For non-trivial behavior changes,
inspect callers, implementations, tests, and documentation that depend on the changed variable or
file. Find every use with `grep -rn '<name>' roles/ playbooks/ inventory/`; never assume every
use is in the diff.

## Authority

Always read `AGENTS.md`. For a role change, read the whole role (defaults,
tasks, handlers, meta) and the playbook that includes it, not only the diff.
For a new or renamed variable, trace every use across `roles/`, `playbooks/`
and `inventory/group_vars/all.yaml`. For a user-visible change, read the
README's playbook and role tables.

## Repository invariants

Check these whenever affected, directly or indirectly:

- **Idempotent.** A second run on the same machine reports no changes. Every
  `command`/`shell` task has a `changed_when` (and `creates`/`removes` where it
  applies) that is true only when something changed; state is queried before
  it is mutated. A task that always reports changed, or that re-downloads or
  rebuilds on every run, is a finding.
- **Every role can be switched off and run alone.** Each role has a
  `<role>_enabled` default and a `when: <role>_enabled | bool` plus a tag with
  its name in the playbook that includes it. A role must work with
  `--tags <role>` on its own: facts, variables or files it needs from another
  role must come from `meta/main.yaml` dependencies or its own tasks, not from
  run order. Disabling a role must not break another.
- **`inventory/group_vars/all.yaml` is generated.** It changes only through
  `generate-group-vars.sh` from the role defaults, in the same commit. A hand
  edit, or a default without the regenerated file, is a finding (CI's
  `generate-group-vars` hook fails on it).
- **The repository is public.** No secrets, tokens, license keys, e-mail
  addresses, host names or other personal data in defaults, tasks, templates,
  commit messages or examples.
- **FQCN everywhere.** `ansible.builtin.*` / `community.general.*` names, and
  `ansible.builtin.command` over `shell` unless a shell feature is needed.
- **Trust anchors are verified.** A new APT repository uses a deb822
  `.sources` file whose `Signed-By` key comes over HTTPS and, where the vendor
  publishes one, is checked against a pinned fingerprint (the `trezor_suite`
  role is the model). A downloaded `.deb`, tarball or AppImage is checked
  against a pinned checksum when one exists. `curl | sh`, `apt_key`, a key in
  `trusted.gpg.d` for a single vendor, or `validate_certs: false` is a finding.
- **Privilege is scoped.** `become` only on the tasks that need it. `make
  install` writes a temporary NOPASSWD sudoers file and removes it whatever the
  playbook's exit code; any change there that can leave it behind (an early
  exit, a signal, a changed file name) is critical.
- **Hardware facts stay honest.** Roles that depend on the GPU facts from
  `playbooks/tasks/pre_tasks.yaml` (`has_nvidia_gpu`, `has_amd_gpu`,
  `has_intel_gpu`) must behave on a machine with none, one or several of them.
- **Defaults follow the README.** A role's default (enabled or not) matches the
  README's role table; a role for software the maintainer does not use is
  disabled by default.
- **Workflows stay pinned and least-privilege.** `contents: read` at the top,
  extra permissions per job with the reason; every action pinned to a full
  commit SHA with a `# vX.Y.Z` comment; inputs reach shell through `env:`.
- **Commit type matches whether it ships.** `svu` derives the release from the commits since the
  last tag, and every commit lands as it is (merge commits). What ships is the playbook: a change
  to what it does on a machine (a role, a playbook, a default, `install_uv.sh`, `make install`)
  typed `chore`, `ci`, `docs` or `refactor` never reaches a release; a `feat` or `fix` on a
  workflow, a hook, a test or a doc cuts a release for nothing; a stray `!` or `BREAKING CHANGE:`
  cuts a major. A revert of a shipped `feat` or `fix` is a `fix`. `svu` also matches `feat`/`fix`
  anywhere before a colon (`prefix:` counts as `fix:`). See `AGENTS.md`.

## Adversarial passes

Do not skim for style. Beyond the generic passes (logic, empty input, error handling, resources,
security), run each pass with "how can this fail?" framing, and name the triggering host state or
value per candidate rather than asserting "looks fine":

- **Second run:** walk every changed task on a machine where it already ran.
  Does it report changed? Does it re-download, re-add a key, append a line
  twice, or restart a service needlessly?
- **Fresh machine:** walk it on a clean install, where a directory, user,
  group, package or repository it assumes does not exist yet.
- **Variations:** the Ubuntu release (`ansible_distribution_release`), a
  package renamed or dropped in a newer release, a missing PPA for a new
  codename, a role disabled while another that used its output stays on,
  `--tags` selecting only this role, `--check` mode.
- **Failure half-way:** a download that fails or returns HTML, a package
  manager lock, a handler that never runs because a later task failed. Is the
  machine left in a state the next run repairs?
- **Quoting and templating:** Jinja in `when:` (never `{{ }}`), unquoted
  values YAML turns into booleans or octal numbers, file modes as strings,
  paths with spaces, `lookup` on the controller versus the host.
- **Contract drift:** compare the change with the README tables, the role's
  defaults, the playbook tags, and the commit/PR intent.
- **A check that can no longer fail:** the gates guard claims nobody re-checks
  by hand. Make the guarded thing go wrong and see whether the check still
  notices: a hand-edited `inventory/group_vars/all.yaml` against the
  `generate-group-vars` hook, a file without the header against
  `scripts/check-license-headers.sh` (a governed-file filter that matches no
  file, an exemption that swallows real code), a broken playbook against
  `ansible-syntax`. A hook that lost `always_run`, a `files:` pattern that no
  longer matches, a new `SKIP` in `pre-commit-all`, a job dropped from
  `ci-result`'s `needs`, or a CI step that adds `|| true` or
  `continue-on-error` is a false pass: a finding.

## Gates

Do not re-run the repository's gates (`make check`, `make ansible-syntax-check`). The implementer is
expected to run them and CI runs them again, but do not assume either happened: report the
verification evidence you actually have (under adversarial-review-loop, `verification.txt` when
supplied, which is the implementer's claim and not proof; when invoked directly, the CI status or
gate output in the PR or session) and what is missing, such as a role's behavior change with no
result from running `make install TAGS=<role>` twice on a throwaway Ubuntu virtual machine (the
second run must report no changes), or a change to `scripts/check-license-headers.sh` with no
evidence that it still fails on a file without the header. A failure in that evidence caused by the
change is a confirmed finding. Never say that a check you did not see passed. Judge whether the
change's tests prove it: a behaviour change needs a check that fails on the old code.

Never run the playbook on the machine you are working on: it changes that machine. There is no
focused runner for a role's behavior, so a suspected finding is confirmed by tracing the task, its
variables and the host state statically. When invoked directly, one hook on the changed file
(`pre-commit run <hook-id> --files <file>`, for a hook that checks only the files it is given) may
be run to confirm a single suspected finding, never a full suite or gate. A candidate that is
neither reproduced nor traced end to end is dropped: never report a finding without the triggering
state and the wrong result or broken invariant.

## Report

Rank findings by severity, worst first. A secret or personal data in the
repository, an unverified download or key, or a leftover privilege escalation
are normally blockers. Skip pure formatting unless it changes meaning or
breaks a required gate.

For each finding:

```text
<path>:<line> - <severity: blocker | high | medium | low>: <one-line defect>
  Failure: <concrete input/state/interleaving -> wrong result or broken invariant>
  Fix: <specific corrective change>
```

Put findings first. Then list open questions or assumptions, followed by a one-line verdict:
**block**, **approve with nits**, or **approve**, and one line:
`Verification evidence: seen … / missing …`. If no findings exist, say so explicitly and briefly
name the failure modes you tried to trigger. Be blunt, but never invent a finding to appear
thorough.
