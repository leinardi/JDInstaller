# AGENTS.md

## What this is

An Ansible playbook that sets up a fresh Ubuntu desktop with the maintainer's packages and settings.
It runs against `localhost` only. Every role can be switched on or off with its `<role>_enabled`
variable, and every playbook with its own; the README is the user-facing contract: which playbooks
and roles exist, what they install, and whether they are enabled by default.

## Common commands

```bash
make install                  # install Ansible if missing, then run playbooks/ubuntu-setup.yaml (asks for the sudo password)
make install TAGS=docker      # run a single role: every role is tagged with its own name
make generate-group-vars      # regenerate inventory/group_vars/all.yaml from the role defaults
make ansible-syntax-check     # syntax-check every playbook, collections from requirements.yml in .galaxy/
make check                    # pre-commit on all files: the local gate, as CI's pre-commit-all
make check-stage              # pre-commit on the staging area only
make pre-commit-install       # install the pre-commit and commit-msg hooks
make mk-common-update         # refresh the shared .mk snippets from leinardi/make-common@v1
scripts/check-license-headers.sh  # the Apache-2.0 header on every code file (also a pre-commit hook)
```

`make check` runs ansible-lint, yamllint, prettier, shellcheck, markdownlint, actionlint, checkmake,
the `generate-group-vars` drift check and the license-header check. Never run `make install` or
`ansible-playbook` to test a change on the machine you are working on: the playbook changes that
machine. Use a throwaway VM.

The Makefile pulls shared snippets from `leinardi/make-common@v1` into `.mk/` on first run. To
refresh: `make mk-common-update`. Project targets live in the local `.mk/*.mk` files listed in
`MK_LOCAL_FILES`, never as recipes in the Makefile.

In CI (`.github/workflows/ci.yaml`), `ci-result` is the one required check. It needs
`pre-commit-all` (every hook over every file), `ansible-syntax`, `conventional-commits`, and the
`ansible-lint` and `shellcheck` reviewdog jobs; the last three only run on pull requests, so they may
be skipped on a push. The other reviewdog jobs only annotate pull requests.

## Layout

- `playbooks/ubuntu-setup.yaml` — the entry point: `tasks/pre_tasks.yaml` (facts such as the GPU
  vendor), then one `import_playbook` per area (`common`, `desktop`, `gaming`, `development`,
  `three_d_printing`, `work`), each gated by `<area>_enabled`.
- `roles/<name>/` — one role per application or setting. `defaults/main.yaml` holds `<name>_enabled`
  and the role's other variables; `tasks/main.yaml` does the work.
- `inventory/hosts.yaml` — `localhost` with a local connection. `inventory/group_vars/all.yaml` is
  generated, see below.
- `generate-group-vars.sh` — concatenates every role's `defaults/main.yaml` into
  `inventory/group_vars/all.yaml`.
- `install_ansible.sh` — installs Ansible from the Ansible PPA where it serves the running release,
  otherwise from Ubuntu.
- `requirements.yml` — the Ansible collections the roles use. `requirements-ci.txt` — the
  ansible-core CI checks the syntax with.
- `scripts/check-license-headers.sh` — the license-header check.
- `scripts/bootstrap-mk-common.sh`, `.mk/` — the shared make snippets from `leinardi/make-common`;
  `.mk/ansible.mk` is local.

### Generated or vendored: never hand-edit

- `inventory/group_vars/all.yaml`: generated from every role's `defaults/main.yaml` by
  `generate-group-vars.sh` (`make generate-group-vars`); the `generate-group-vars` hook fails when it
  drifts.
- `.mk/help.mk`, `.mk/pre-commit.mk`, `.mk/password.mk` and `.mk/.mk-common-version`: fetched from
  `leinardi/make-common`, refreshed with `make mk-common-update`.
- `scripts/bootstrap-mk-common.sh`: also from make-common; a change is ported upstream.

## Ansible rules

- Use fully qualified collection names (FQCN) for every module, e.g. `ansible.builtin.command`.
- Never edit `inventory/group_vars/all.yaml` by hand: it is generated from each role's
  `defaults/main.yaml`. Edit the role defaults, then run `make generate-group-vars`, and commit
  both. CI fails when they disagree.
- A new role gets a `<role>_enabled` default, a `when: <role>_enabled | bool` and a tag with its
  name in the playbook that includes it, and a row in the README. A role for software the maintainer
  does not use is disabled by default.
- Never hardcode secrets or personal data: the repository is public. Take them from role-prefixed
  variables.
- Prefer `ansible.builtin.command` over `ansible.builtin.shell` unless shell features are truly
  needed.
- Keep tasks idempotent: query the current state before changing it, so a second run reports no
  changes.
- Give every `command` or `shell` task an explicit `changed_when`.
- A new third-party APT repository uses a deb822 `.sources` file with a `Signed-By` key; verify a
  downloaded key or binary against a pinned fingerprint or checksum where the vendor publishes one.
- A new `# noqa` explains why the rule does not apply here, not which rule fired.

## License headers

Every code file (shell and Python scripts, the Makefile, the repo-local `.mk` fragments) starts with
the Apache-2.0 notice (`Copyright <year> Roberto Leinardi.` and the short license text, as in any
shell script here), with the year the file was created. The `check-license-headers` pre-commit hook
(`scripts/check-license-headers.sh`) fails on any that lacks it. YAML, JSON, Markdown and Jinja
templates are never governed, so the playbooks, roles and the generated
`inventory/group_vars/all.yaml` carry no header; the make-common files are exempt.

## Markdown

Prose wraps at 100 columns (markdownlint `line-length`, `.editorconfig`); tables, code blocks and
headings may run longer. Never wrap inside a table, a code block or a link target.

## Validation matrix

Run before considering an edit done. `make check` applies to every row.

| You edited | Run |
| --- | --- |
| `roles/**`, `playbooks/**`, `inventory/**`, `requirements.yml` | `make check`, `make ansible-syntax-check`; a role default also needs `make generate-group-vars`, committed with it |
| a role's behaviour | the above, then `ansible-playbook playbooks/ubuntu-setup.yaml --tags <role>` twice on a throwaway VM: the second run reports no changes |
| `generate-group-vars.sh` | `make generate-group-vars`: `inventory/group_vars/all.yaml` must not change unless intended |
| `install_ansible.sh`, `.mk/ansible.mk`, `Makefile` | `make check` (shellcheck, checkmake), `make help`; `make install` only on a throwaway VM |
| `scripts/check-license-headers.sh`, any new code file | `scripts/check-license-headers.sh`; for the script, a file without the header must still fail it |
| `.github/workflows/**`, `.github/dependabot.yml` | `pre-commit run actionlint --all-files` |
| `.pre-commit-config.yaml` | `make check`; a new hook a dedicated CI job runs is named in `pre-commit-all`'s `SKIP` |
| `scripts/bootstrap-mk-common.sh` | port the change to make-common; `make help` proves the snippets still load |
| `**/*.md`, `.agents/skills/**` | `make check` (markdownlint); prose wrapped at 100 columns |

## Project skills

Skills live in `.agents/skills/` (symlinked as `.claude/skills`). Load `adversarial-review` for any
review request ("review my diff", "is this ready to merge").

## Commit messages

All commits MUST be Conventional Commits 1.0.0 **with a scope**:
`<type>(<scope>)[!]: <description>`, optional blank-line body and footers. Use the role or playbook
name as the scope. Enforced by the `conventional-pre-commit` `commit-msg` hook (`--force-scope`,
installed by `make pre-commit-install`) and by the `conventional-commits` CI job. Types: `feat`,
`fix`, `docs`, `test`, `refactor`, `perf`, `build`, `ci`, `chore`, `style`, `revert`. Breaking
changes use `!` before `:` or a `BREAKING CHANGE:` footer. Release notes are not built from these
messages: the release lists the merged pull requests by title. Examples:
`fix(docker): add the user to the docker group`, `feat(obs): add an OBS Studio role`.

A release with no explicit version is derived by `svu` from the commits since the last `vX.Y.Z` tag,
so a wrong type ships a wrong version:

| Release | Commit | Example |
| --- | --- | --- |
| major | any type with `!` before the colon, or a `BREAKING CHANGE:` footer | `feat(common)!: drop Ubuntu 24.04 support` |
| minor | `feat` | `feat(obs): add an OBS Studio role` |
| patch | `fix` | `fix(docker): add the user to the docker group` |
| none | everything else: `perf`, `refactor`, `build`, `ci`, `chore`, `docs`, `style`, `test`, `revert` | `docs(readme): list the gaming roles` |

The highest bump among the commits wins; with only "none" commits since the last tag, a release with
no version fails with "nothing to bump".

**Pick the type by whether the change should ship, not by what kind of change it is.** What ships
here is the playbook: anything that changes what it does on a machine and that users should receive
is `fix` (or `feat`), even when it is a performance improvement, a refactor or a revert. Use `perf`,
`refactor`, `style` and `revert` only when the commit is deliberately not meant to trigger a release
on its own. A `revert` of a shipped `feat` or `fix` is itself a `fix`. `svu` matches `feat`/`fix`
anywhere in the subject (e.g. `prefix:` counts as `fix:`), so avoid a word ending in `feat` or `fix`
directly before a colon in other subjects. PRs land as merge commits, so every commit counts, not
just the PR title. See [`CONTRIBUTING.md`](CONTRIBUTING.md#releasing).
