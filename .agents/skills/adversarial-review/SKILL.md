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

This skill defines the review procedure and reporting. `AGENTS.md` and the
README remain the sources of truth.

Copy this checklist and tick items as you go:

```text
Review progress:
- [ ] 1. Diff and intent established (default scope if none given)
- [ ] 2. AGENTS.md, the whole changed role and its playbook read
- [ ] 3. Repository invariants checked
- [ ] 4. Adversarial passes run
- [ ] 5. Findings confirmed or dropped; gates run
- [ ] 6. Report written
```

## 1. Establish the diff

Never review from memory or only from the user's description. Read the actual
diff and determine its intent. With no scope given, review the uncommitted
work; if the tree is clean, review the branch against `master`.

| User intent | Command |
| --- | --- |
| "my work", "before I commit", uncommitted changes | `git status --short`, then `git diff HEAD`; inspect untracked files too |
| staged changes only | `git diff --staged` |
| branch, "this PR", "ready to merge" | `git diff master...HEAD` |
| specific commit range | `git diff <base>..<head>` |
| GitHub PR number | `gh pr view <n>` for intent and metadata, then `gh pr diff <n>` |

Read `git log --oneline` for the reviewed range and any linked issue or PR
body. Code that works but does something other than the stated intent is a
finding.

Read every changed file with enough surrounding context to understand its
contracts. For non-trivial behavior changes, inspect callers, implementations,
tests, and documentation that depend on the changed variable or file. Find
every use with `grep -rn '<name>' roles/ playbooks/ inventory/`; never assume
every use is in the diff.

## 2. Load project authority

Always read `AGENTS.md`. For a role change, read the whole role (defaults,
tasks, handlers, meta) and the playbook that includes it, not only the diff.
For a new or renamed variable, trace every use across `roles/`, `playbooks/`
and `inventory/group_vars/all.yaml`. For a user-visible change, read the
README's playbook and role tables.

## 3. Repository invariants

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

## 4. Adversarial passes

Do not skim for style. Run each pass with "how can this fail?" framing:

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

For each candidate finding, reproduce it or trace the failing host state end
to end. If that confirms it, report it. If not, dig once more; if it is still
unconfirmed, drop it. Never report a finding without the triggering state and
the wrong result or broken invariant.

## 5. Verify findings and gates

Never verify by running the playbook on the machine you are working on: it
changes that machine. Use the static gates, and a throwaway Ubuntu virtual
machine for anything that needs a real run.

| Diff touched | Run |
| --- | --- |
| roles, playbooks, inventory | `make check`, then `make ansible-syntax-check` |
| a role's behavior | the above, then `ansible-playbook playbooks/ubuntu-setup.yaml --tags <role>` twice on a throwaway VM: the second run must report no changes |
| workflows, Makefile, scripts | `make check` |
| docs or skill only | `make check` |

A failing gate is a confirmed finding when caused by the reviewed change. If a
gate cannot run, state why and mark it unverified; never imply it passed.

## 6. Report

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

Put findings first. Then list open questions or assumptions, followed by a
one-line verdict: **block**, **approve with nits**, or **approve**. Include gates
actually run and gates not run. If no findings exist, say so explicitly and
briefly name the failure modes you tried to trigger. Be blunt, but never invent
a finding to appear thorough.
