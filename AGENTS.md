# AGENTS.md

## What this is

An Ansible playbook that sets up a fresh Ubuntu desktop with the maintainer's packages and settings. It runs against
`localhost` only. Every role can be switched on or off with its `<role>_enabled` variable, and every playbook with its own; the
README is the user-facing contract: which playbooks and roles exist, what they install, and whether they are enabled by default.

## Common commands

```bash
make install                        # install Ansible if missing, then run playbooks/ubuntu-setup.yaml (asks for the sudo password)
make install TAGS=docker            # run a single role: every role is tagged with its own name
make generate-group-vars            # regenerate inventory/group_vars/all.yaml from the role defaults
make ansible-syntax-check           # syntax-check every playbook, collections from requirements.yml in .galaxy/; also runs in CI
make check                          # pre-commit on all files: ansible-lint, yamllint, prettier, shellcheck, markdownlint
make check-stage                    # pre-commit on the staging area only
```

Before calling a change done, run `make check` and `make ansible-syntax-check`. Never run `make install` or
`ansible-playbook` to test a change on the machine you are working on: the playbook changes that machine. Use a throwaway VM.

The Makefile pulls shared snippets from `leinardi/make-common@v1` into `.mk/` on first run. To refresh: `make mk-common-update`.
Project targets live in the local `.mk/*.mk` files listed in `MK_LOCAL_FILES`, never as recipes in the Makefile.

## Layout

- `playbooks/ubuntu-setup.yaml` — the entry point: `tasks/pre_tasks.yaml` (facts such as the GPU vendor), then one
  `import_playbook` per area (`common`, `desktop`, `gaming`, `development`, `three_d_printing`, `work`), each gated by
  `<area>_enabled`.
- `roles/<name>/` — one role per application or setting. `defaults/main.yaml` holds `<name>_enabled` and the role's other
  variables; `tasks/main.yaml` does the work.
- `inventory/hosts.yaml` — `localhost` with a local connection. `inventory/group_vars/all.yaml` is generated, see below.
- `generate-group-vars.sh` — concatenates every role's `defaults/main.yaml` into `inventory/group_vars/all.yaml`.
- `install_ansible.sh` — installs Ansible from the Ansible PPA where it serves the running release, otherwise from Ubuntu.
- `requirements.yml` — the Ansible collections the roles use. `requirements-ci.txt` — the ansible-core CI checks the syntax with.

## Ansible rules

- Use fully qualified collection names (FQCN) for every module, e.g. `ansible.builtin.command`.
- Never edit `inventory/group_vars/all.yaml` by hand: it is generated from each role's `defaults/main.yaml`. Edit the role
  defaults, then run `make generate-group-vars`, and commit both. CI fails when they disagree.
- A new role gets a `<role>_enabled` default, a `when: <role>_enabled | bool` and a tag with its name in the playbook that
  includes it, and a row in the README. A role for software the maintainer does not use is disabled by default.
- Never hardcode secrets or personal data: the repository is public. Take them from role-prefixed variables.
- Prefer `ansible.builtin.command` over `ansible.builtin.shell` unless shell features are truly needed.
- Keep tasks idempotent: query the current state before changing it, so a second run reports no changes.
- Give every `command` or `shell` task an explicit `changed_when`.
- A new third-party APT repository uses a deb822 `.sources` file with a `Signed-By` key; verify a downloaded key or binary against a
  pinned fingerprint or checksum where the vendor publishes one.
- A new `# noqa` explains why the rule does not apply here, not which rule fired.

## Project skills

Skills live in `.agents/skills/` (symlinked as `.claude/skills`). Load `adversarial-review` for any review request ("review my
diff", "is this ready to merge").

## Commit messages

All commits MUST be Conventional Commits 1.0.0 **with a scope**: `<type>(<scope>)[!]: <description>`, optional blank-line body and
footers. Use the role or playbook name as the scope. Enforced by the `conventional-pre-commit` `commit-msg` hook (`--force-scope`,
installed by `make pre-commit-install`) and by the `conventional-commits` CI job. Breaking changes use `!` before `:` or a
`BREAKING CHANGE:` footer. Release notes are not built from these messages: the release lists the merged pull requests by title.
Examples: `fix(docker): add the user to the docker group`, `feat(obs): add an OBS Studio role`.

A release with no explicit version is derived by `svu` from the commits since the last `vX.Y.Z` tag, so a wrong type ships a wrong
version:

| Release | Commit | Example |
| --- | --- | --- |
| major | any type with `!` before the colon, or a `BREAKING CHANGE:` footer | `feat(common)!: drop Ubuntu 24.04 support` |
| minor | `feat` | `feat(obs): add an OBS Studio role` |
| patch | `fix` | `fix(docker): add the user to the docker group` |
| none | everything else: `perf`, `refactor`, `build`, `ci`, `chore`, `docs`, `style`, `test`, `revert` | `docs(readme): list the gaming roles` |

The highest bump among the commits wins; with only "none" commits since the last tag, a release with no version fails with
"nothing to bump". **Pick the type by whether the change should ship, not by what kind of change it is:** a refactor or a revert
that changes what the playbook does is a `fix`. `svu` matches `feat`/`fix` anywhere in the subject (e.g. `prefix:` counts as
`fix:`), so avoid a word ending in `feat` or `fix` directly before a colon in other subjects. Every commit of a pull request
lands on `master`, so every commit counts, not just the pull request title. See [`CONTRIBUTING.md`](CONTRIBUTING.md#releasing).
