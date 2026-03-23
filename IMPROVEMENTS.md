# JDInstaller — Comprehensive Improvement Review

> Generated: 2026-03-18
> Scope: full repository (pfSense-related code excluded per instruction)
> Basis: direct file reads across all 64 roles, all playbooks, CI configs, pre-commit config, Makefile, scripts, and `.claude` directory

---

## 1. Executive Summary

JDInstaller is a mature, well-structured single-user Ubuntu desktop automation project. The overall quality is high: FQCN modules are used consistently, most
tasks are idempotent, CI/CD is non-trivial (reviewdog integration, ansible-lint, yamllint, actionlint, shellcheck, prettier), and complex roles like
`trezor_suite` and `orcaslicer` are model examples of robust Ansible design.

The main pain points fall into four clusters:

1. **Two active bugs** — a swapped variable name in role defaults (gamemode/gparted) that propagates to `all.yaml`, and broken file paths in the CI functional
   test that would silently fail.
2. **Security posture** — real registration data and identifiable defaults live in a public `group_vars/all.yaml`, and there is no vault usage anywhere.
3. **Repetition and inconsistency** — the `gsettings` role is 160+ lines of cut-paste pairs; variable style is mixed (flat-prefixed vs dict); tagging is
   inconsistent across playbooks.
4. **Maintainability friction** — `davinci_resolve` is a 575-line monolithic task file; `mangohud` always rebuilds; the `TODO.md` is a raw notes dump; the
   `.claude` directory is minimal.

No major rewrites are needed. All improvements are incremental.

---

## 2. Highest-Priority Improvements

### BUG-1 — Swapped variable names in `gamemode` and `gparted` role defaults

**Why it matters:** The `gparted` role's `defaults/main.yaml` defines `gamemode_enabled: true` and the `gamemode` role's `defaults/main.yaml` defines
`gparted_enabled: true`. These are the wrong variable in the wrong role. `generate-group-vars.sh` propagates this directly into `inventory/group_vars/all.yaml`,
where lines 154–155 read `gamemode_enabled: true` under `# Variables from roles/gamemode` and lines 181–182 read `gparted_enabled: true` under
`# Variables from roles/gparted`. Any user who disables `gamemode_enabled: false` in `all.yaml` actually disables `gparted`, and vice versa.

**Evidence:**

- `roles/gamemode/defaults/main.yaml` line 2: `gparted_enabled: true`
- `roles/gparted/defaults/main.yaml` line 2: `gamemode_enabled: true`
- `inventory/group_vars/all.yaml` lines 154–182 confirm the swap

**Recommendation:** Swap the variable names back to their correct roles:

- `roles/gamemode/defaults/main.yaml` → `gamemode_enabled: true`
- `roles/gparted/defaults/main.yaml` → `gparted_enabled: true`
- Regenerate `inventory/group_vars/all.yaml` via `make generate-group-vars`

**Expected benefit:** Correct enable/disable behaviour for both roles.
**Effort:** Trivial (2-line fix + regenerate).
**Priority:** High

---

### BUG-2 — Broken file paths in CI functional test (`ubuntu-test.yaml`)

**Why it matters:** The `test-all-packages-besides-davinci` job references paths that do not exist, meaning it will always fail or silently skip the sed
mutation:

- `sed -i '…' group_vars/all.yml` — the file is at `inventory/group_vars/all.yaml` (different prefix, `.yaml` not `.yml`)
- `ansible-playbook ubuntu-setup.yml` — the file is at `playbooks/ubuntu-setup.yaml`

The `test-default-packages` job uses `make install` (which works) but `test-all-packages-besides-davinci` bypasses `make` and invokes the playbook directly with
wrong paths.

**Evidence:**

- `.github/workflows/ubuntu-test.yaml` lines 88–91:

  ```yaml
  sed -i '/davinci_resolve_enabled: false/!s/_enabled: false/_enabled: true/' group_vars/all.yml
  …
  run: ansible-playbook ubuntu-setup.yml -vvv
  ```

- Actual paths: `inventory/group_vars/all.yaml` and `playbooks/ubuntu-setup.yaml`

**Recommendation:** Fix both paths to `inventory/group_vars/all.yaml` and `playbooks/ubuntu-setup.yaml`. Also add a checkout step at the top of
`test-default-packages` (that job uses `make install` which clones fresh, but if the CI runner already has the repo checked out from the push event, skipping a
checkout step is unusual and can be confusing).

**Expected benefit:** CI second job actually tests what it says it tests.
**Effort:** Trivial (2-line fix).
**Priority:** High

---

### BUG-3 — `gaming.yaml` playbook has wrong `name:` header

**Why it matters:** `playbooks/gaming.yaml` is imported under `tags: gaming` by `ubuntu-setup.yaml`, but its internal YAML name is `Ubuntu Work Playbook` — the
same as `work.yaml`. This creates noise in `ansible-playbook` output and makes it harder to understand execution logs.

**Evidence:**

- `playbooks/gaming.yaml` line 2: `name: Ubuntu Work Playbook`
- `playbooks/work.yaml` line 2: `name: Ubuntu Work Playbook`

**Recommendation:** Rename to `name: Ubuntu Gaming Playbook` in `gaming.yaml`.
**Effort:** Trivial.
**Priority:** High

---

### BUG-4 — `mangohud` version string has trailing space

**Why it matters:** `mangohud.version: "v0.8.1 "` contains a trailing space, which will be passed verbatim to `git checkout` and will likely fail with "pathspec
not found" unless git strips it.

**Evidence:** `inventory/group_vars/all.yaml` line 223: `version: "v0.8.1 "`
Also in `roles/mangohud/defaults/main.yaml`.

**Recommendation:** Remove trailing space: `version: "v0.8.1"`.
**Effort:** Trivial.
**Priority:** High

---

## 3. Repository Structure and Architecture

### S-1 — `gaming.yaml` playbook name is misleading (see BUG-3 above)

### S-2 — `TODO.md` is an unstructured scratch pad

**Why it matters:** `TODO.md` contains raw URLs, one-liners, and fragments with no priority, context, or assignee. It is checked into version control and
visible to contributors but carries no actionable information.

**Evidence:** `TODO.md` full content is 17 lines of unformatted links and phrases, e.g. `pinta`, `calibre`, `Fix tags (see common.yaml)`.

**Recommendation:** Either delete `TODO.md` (use GitHub Issues instead) or restructure it with sections, priority, and brief context for each item. The note
`Fix tags (see common.yaml)` is the only substantive item — track it somewhere actionable.
**Effort:** Low.
**Priority:** Low

---

### S-3 — `development` role not tagged in `development.yaml`

**Why it matters:** Every other role in every playbook gets a `tags:` field that matches its role name, enabling `make install TAGS=<role>` to run a single
role. The `development` role in `development.yaml` has no tag. Running `make install TAGS=development` will skip it (the playbook-level tag `tags: development`
does fire, but not the role-level tag).

**Evidence:** `playbooks/development.yaml` lines 5–7 — `role: development` has no `tags:` key, while `role: docker` line 8 has `tags: docker`.

**Recommendation:** Add `tags: development` to the `development` role entry in `development.yaml`.
**Effort:** Trivial.
**Priority:** Medium

---

### S-4 — `desktop` role not tagged in `desktop.yaml`

**Same pattern as S-3.** `role: desktop` in `desktop.yaml` has no `tags:` entry.

**Evidence:** `playbooks/desktop.yaml` lines 11–12.

**Recommendation:** Add `tags: desktop`.
**Effort:** Trivial.
**Priority:** Medium

---

### S-5 — Role discovery order in `generate-group-vars.sh` is filesystem-dependent

**Why it matters:** `for role in roles/*` iterates in filesystem order, which is typically alphabetical on most Linux systems but not guaranteed. A reordering
of files on a different OS or filesystem could change the output of `all.yaml`. The script is simple but fragile as a contract.

**Evidence:** `generate-group-vars.sh` line 13: `for role in roles/*`

**Recommendation:** Sort explicitly: `for role in $(ls -d roles/* | sort)`. This makes the ordering deterministic and platform-independent.
**Effort:** Trivial.
**Priority:** Low

---

## 4. Ansible Organization and Patterns

### A-1 — `gsettings` role is 160 lines of copy-pasted get/set pairs

**Why it matters:** Each GNOME setting requires two tasks (get + conditional set), with the same `environment:` block repeated 10 times. This is difficult to
extend, easy to introduce typos in, and violates DRY. There are 10 settings, each needing their own register variable, when a loop over a data structure would
be cleaner.

**Evidence:** `roles/gsettings/tasks/main.yaml` — 10 identical get/set pairs, each with:

```yaml
environment:
  DBUS_SESSION_BUS_ADDRESS: "unix:path=/run/user/{{ ansible_user_uid }}/bus"
```

repeated verbatim 20 times.

**Recommendation:** Refactor to a loop over a list of dicts:

```yaml
# defaults/main.yaml
gsettings:
  settings:
    - schema: org.gnome.shell.extensions.dash-to-dock
      key: click-action
      value: "'minimize'"
    - schema: org.gnome.TextEditor
      key: tab-width
      value: "4"
```

Then one task pair (or a single task using the `community.general.dconf` module) handles all settings. The `community.general.dconf` module is purpose-built for
this and avoids running shell commands entirely.

**Expected benefit:** ~140 lines → ~20 lines; adding a new setting is one list entry; no env block repetition.
**Effort:** Medium (refactor + test).
**Priority:** Medium

---

### A-2 — `davinci_resolve/tasks/main.yaml` is a 575-line monolith

**Why it matters:** It is the largest file in the repo by far, covering API registration, download, extraction, RPATH patching, library symlinking, desktop
entry management, and group management. Bugs and logic are hard to isolate. `kvm` handles complexity by splitting into 6 task files — the same pattern should be
applied here.

**Evidence:** `roles/davinci_resolve/tasks/main.yaml` — 575 lines. `roles/kvm/tasks/` has 6 files.

**Recommendation:** Split into subtask files:

- `tasks/install.yaml` — download + extract
- `tasks/libraries.yaml` — RPATH patching + symlinks
- `tasks/desktop.yaml` — .desktop/.menu/.icon files
- `tasks/groups.yaml` — davinci group management
- `tasks/main.yaml` — orchestrator that includes the above

**Effort:** Medium.
**Priority:** Medium

---

### A-3 — `mangohud` is not idempotent (always rebuilds from source)

**Why it matters:** Every run clones the repo and builds from source unconditionally. On a re-run, even with the same version, all build tasks will execute and
report `changed`. This is slow (~2–5 minutes) and meaningless after the initial install.

**Evidence:** `roles/mangohud/tasks/main.yaml` — `meson setup`, `meson compile`, `meson install` all have `changed_when: true` unconditionally.

**Recommendation:** Add a pre-check:

```yaml
- name: Check installed MangoHud version
  ansible.builtin.command: mangohud --version
  register: _mangohud_installed_version
  changed_when: false
  failed_when: false

- name: Set install needed flag
  ansible.builtin.set_fact:
    _mangohud_needs_build: >-
      {{ _mangohud_installed_version.rc != 0
         or (mangohud.version | trim) not in _mangohud_installed_version.stdout }}
```

Then gate the entire build block on `_mangohud_needs_build`.

**Expected benefit:** Re-runs are fast and clean; `changed` output is meaningful.
**Effort:** Low.
**Priority:** Medium

---

### A-4 — `has_nvidia_gpu` fact uses `rc` check; AMD/Intel use `stdout` length — inconsistent

**Why it matters:** The three GPU detection tasks in `playbooks/tasks/pre_tasks.yaml` use different logic:

- AMD: `lspci_output_amd.stdout | length > 0` ✓
- Intel: `lspci_output_intel.stdout | length > 0` ✓
- NVIDIA: `lspci_output.rc | default(1) == 0` — also uses a confusingly non-descriptive register name `lspci_output` instead of `lspci_output_nvidia`

If `lspci` fails for any reason, `rc` defaults to 1 (correctly treating no GPU), but the inconsistency makes the code harder to audit.

**Evidence:** `playbooks/tasks/pre_tasks.yaml` lines 54–64.

**Recommendation:** Rename register to `lspci_output_nvidia` and use `stdout | length > 0` for consistency.
**Effort:** Trivial.
**Priority:** Low

---

### A-5 — `pre_tasks.yaml` GPU detection uses `ansible.builtin.shell` instead of `ansible.builtin.command`

**Why it matters:** `CLAUDE.local.md` rule: "For `midclt` calls, use `ansible.builtin.command`, not shell, unless shell is truly unavoidable." The lspci lines
use piped shell commands (`lspci | grep -i …`), which require shell. However the `| grep` can be replaced by using `ansible.builtin.command` for `lspci` and
then using Ansible filters (`| select('search', …)`) on `stdout_lines`.

**Evidence:** `playbooks/tasks/pre_tasks.yaml` lines 28–64 — three `ansible.builtin.shell` blocks.

**Recommendation:** Use `ansible.builtin.command` for lspci, then filter with `stdout_lines | select('search', '(?i)vga.*amd')`.
**Effort:** Low.
**Priority:** Low

---

### A-6 — Variable style is inconsistent: flat-prefixed vs dict

**Why it matters:** Most complex roles use a dict variable (e.g. `orcaslicer_appimage: {version: …, install_dir: …}`), which groups related config cleanly. But
`nodejs` uses flat-prefixed variables scattered across lines:

- `nodejs_version_major`
- `nodejs_repo_name`
- `nodejs_repo_uri`

The `kvm_gpu_passthrough` variable lives outside the `kvm:` dict entirely, with a comment that's separate from the dict definition.

**Evidence:**

- `inventory/group_vars/all.yaml` lines 250–253 (nodejs flat style)
- `inventory/group_vars/all.yaml` lines 208–212 (kvm mixed style)

**Recommendation:** Standardize: move `nodejs_version_major`, `nodejs_repo_name`, `nodejs_repo_uri` into a `nodejs:` dict; move `kvm_gpu_passthrough` into the
`kvm:` dict. This is a breaking change to variable names so update tasks accordingly. Skip if the flatter style is intentional for these roles.
**Effort:** Medium.
**Priority:** Low

---

### A-7 — `common` role performs unconditional `apt upgrade`

**Why it matters:** `ansible.builtin.apt: upgrade: true` upgrades all installed packages on every run. On a managed system, this is usually desirable on first
run but unexpected on subsequent re-runs (could upgrade packages the user hasn't reviewed). It also cannot be skipped individually. There is no `dist_upgrade`
and no dry-run confirmation.

**Evidence:** `roles/common/tasks/main.yaml` line 18–20.

**Recommendation:** Either move the upgrade to its own role/tag so it can be selectively run (`make install TAGS=upgrade`), or gate it behind a variable like
`common_upgrade_packages: false` in defaults.
**Effort:** Low.
**Priority:** Low

---

### A-8 — `davinci_resolve` role lacks an idempotency check

**Why it matters:** Unlike `trezor_suite` and `orcaslicer`, the `davinci_resolve` role has no early-exit "is this version already installed?" check. Every run
re-downloads (several GBs), re-extracts, and re-patches the entire installation. This is extremely expensive and means the role cannot be included in routine
re-runs.

**Evidence:** `roles/davinci_resolve/tasks/main.yaml` — first task after setting facts immediately installs deps and hits the Blackmagic API; no stat check of
existing installation.

**Recommendation:** Add a version detection step similar to `trezor_suite` (check a version marker file or the installed binary version), and gate the
installation block on a `_davinci_needs_install` fact.
**Effort:** Medium.
**Priority:** Medium

---

### A-9 — `orcaslicer` version check doesn't detect version change (only presence)

**Why it matters:** `_orcaslicer_ai_do_install` is set to `not binary_stat.exists or force_reinstall`. If OrcaSlicer is installed at the wrong version, the role
will report "already installed" and skip. Version checking (like `trezor_suite` does via the desktop file's `X-AppImage-Version`) is absent.

**Evidence:** `roles/orcaslicer/tasks/main.yaml` lines 33–37.

**Recommendation:** Write the installed version (e.g. `_orcaslicer_release_tag`) to a marker file at install time, and check it on subsequent runs to detect
version drift. Mirror the pattern in `trezor_suite`.
**Effort:** Low.
**Priority:** Medium

---

### A-10 — `orcaslicer` and `orcaslicer_flatpak` are parallel roles for the same app

**Why it matters:** Two separate roles install the same application via different methods (AppImage vs Flatpak). Both are enabled in `all.yaml` simultaneously (
`orcaslicer_enabled: true` and `orcaslicer_flatpak_enabled: true`), which means by default both are installed. There is no mutual exclusion.

**Evidence:**

- `inventory/group_vars/all.yaml` lines 268 and 296: both `_enabled: true`
- Both roles exist under `roles/orcaslicer/` and `roles/orcaslicer_flatpak/`

**Recommendation:** Either disable one by default (decide on the canonical method and mark the other `false`), or add a check/assertion in `ubuntu-setup.yaml`
that fails if both are enabled. Document the rationale for having two install methods.
**Effort:** Low.
**Priority:** Medium

---

## 5. Docker / Swarm / Compose Review

There are no Docker Compose or Swarm stack files in this repository. The `docker` role installs the Docker Engine and CLI using the official deb822-format APT
repository. This is clean and correct.

### D-1 — Docker role does not verify APT key origin

**Why it matters:** The docker role uses `signed_by` with an `https://` URL directly in `deb822_repository`. This is valid, but if the URL is unavailable or
compromised, there is no fingerprint assertion like `trezor_suite` performs.

**Evidence:** `roles/docker/tasks/main.yaml` (via `deb822_repository` with `signed_by` URL).

**Recommendation:** Consider pinning the expected GPG fingerprint and asserting it matches, similar to the `trezor_suite` pattern. Alternatively, use the
`get_url` module to download the key first, then pass the local path to `signed_by`. This is medium-severity in a personal homelab context.
**Effort:** Low.
**Priority:** Low

---

## 6. Security and Secret-Handling Review

### SEC-1 — DaVinci Resolve registration data is public in a committed file

**Why it matters:** `inventory/group_vars/all.yaml` is committed to a public GitHub repository. It contains `email: someone@canonical.com`,
`phone: 202-555-0194`, and a full US street address. While these are obviously placeholder/fake values, the pattern teaches users that this is the correct way
to configure personal registration data — which means real users may put their actual email/phone/address in `group_vars/all.yaml` and commit it publicly.

**Evidence:** `inventory/group_vars/all.yaml` lines 83–87.

**Recommendation:**

1. Add a comment explaining these are fake defaults and must be overridden via a local vars file or `--extra-vars`
2. Create a `davinci_resolve_registration.yaml.example` file users can copy and customise
3. Add `*_registration.yaml` and `*_credentials.yaml` patterns to `.gitignore`
4. Long term: use `ansible-vault` for any field that would contain real PII

**Effort:** Low (documentation + gitignore).
**Priority:** High (public repo, PII risk for users who adapt the project)

---

### SEC-2 — No vault usage anywhere in the repository

**Why it matters:** There are no `ansible-vault` encrypted files, no `vault_*` variable references, and no vault password file configuration. For a personal
project this is often acceptable, but since `all.yaml` is committed publicly and the project advertises itself as adaptable to other setups, new adopters have
no template for handling secrets.

**Evidence:** `grep -r 'vault_' roles/ inventory/` returns no matches.

**Recommendation:** Add a brief "Secrets" section to `README.md` explaining that credentials (DaVinci email, any future API keys) should be stored in a
`vault.yaml` file excluded from git. Provide a `vault.yaml.example` template. This is documentation, not code change.
**Effort:** Low.
**Priority:** Medium

---

### SEC-3 — `graphics_drivers` role fetches GPG key via URL without fingerprint assertion

**Why it matters:** `ansible.builtin.deb822_repository` with `signed_by: https://keyserver.ubuntu.com/…` trusts whatever the keyserver returns at that URL. If
the keyserver were compromised or the URL returned a different key, the repository would be trusted without verification.

**Evidence:** `roles/graphics_drivers/tasks/main.yaml` line 10.

**Recommendation:** Pin the expected fingerprint and assert it (as `trezor_suite` does), or at minimum download-and-compare to a hardcoded fingerprint. For a
personal homelab the risk is low but the pattern is worth establishing.
**Effort:** Low.
**Priority:** Low

---

### SEC-4 — `davinci_resolve` registration POST includes hardcoded cookie

**Why it matters:** `roles/davinci_resolve/tasks/main.yaml` line 84 includes:

```yaml
Cookie: "_ga=GA1.2.1849503966.1518103294; _gid=GA1.2.953840595.1518103294"
```

These are hardcoded Google Analytics cookies. They are non-sensitive (tracking IDs), but they represent a specific real identity/session and are committed to a
public repo. More practically, they may expire and break the registration POST.

**Evidence:** `roles/davinci_resolve/tasks/main.yaml` line 84.

**Recommendation:** Remove the `Cookie:` header or replace with a generated/throwaway value. The Blackmagic API registration endpoint likely does not require
valid GA cookies.
**Effort:** Trivial.
**Priority:** Medium

---

### SEC-5 — `trezor_suite` cache dir is `/tmp/trezor-suite` (world-readable default)

**Why it matters:** The cache dir for trezor suite is `/tmp/trezor-suite` with mode `0700` — this is correct. However, the AppImage is downloaded there before
GPG verification, which is fine. The security pattern here is actually a **strength** worth noting: fingerprint assertion before install is a model for other
roles.

**Recommendation:** No change needed. Consider documenting this pattern as the standard for other roles that download binaries (orcaslicer, hadolint, etc.).
**Priority:** N/A (positive note)

---

## 7. CI, Linting, Testing, and Automation

### CI-1 — `ubuntu-test.yaml` has broken paths (see BUG-2 above, highest priority)

### CI-2 — Functional tests only run on `master` and `release`, not on PRs

**Why it matters:** The `ubuntu-test.yaml` workflow triggers on `push` to `master` or `release` and `workflow_dispatch`, but not on `pull_request`. This means a
PR that breaks role installation is not caught until it's merged. The CI check workflow (`ci.yaml`) runs on PRs but only does linting — it does not run the
playbook.

**Evidence:** `.github/workflows/ubuntu-test.yaml` lines 3–12.

**Recommendation:** Add `pull_request:` to the `on:` trigger, but consider making it conditional (e.g. only if roles or playbook files changed) to avoid 2-hour
CI runs on every docs-only PR. GitHub `paths:` filter can restrict it to `roles/**`, `playbooks/**`, `inventory/**`.
**Effort:** Low.
**Priority:** Medium

---

### CI-3 — `test-default-packages` job does not use `actions/checkout`; it clones manually

**Why it matters:** `test-default-packages` installs git/make, then `git clone --no-checkout` and `git fetch origin $GITHUB_SHA` / `git checkout $GITHUB_SHA`.
This works but is fragile (depends on the repo being public), non-standard (every other job uses `actions/checkout`), and bypasses standard caching/fetching
optimisations.

**Evidence:** `.github/workflows/ubuntu-test.yaml` lines 44–51.

**Recommendation:** Use `actions/checkout` with `ref: ${{ github.sha }}` and then just run `make install` from the checked-out directory. This is simpler and
aligns with `test-all-packages-besides-davinci`.
**Effort:** Low.
**Priority:** Low

---

### CI-4 — `ansible-lint` skip rule `var-naming[no-role-prefix]` broadens scope of non-prefixed variables

**Why it matters:** `var-naming[no-role-prefix]` is silenced globally in `.ansible-lint`. This means the linter won't catch variables like `download_id`,
`product`, `package`, `pkgver` in `davinci_resolve` — all of which are unscoped and could leak into the play's variable namespace, causing subtle conflicts if
other roles set similarly-named variables.

**Evidence:** `.ansible-lint` line 5: `- var-naming[no-role-prefix]`
`roles/davinci_resolve/tasks/main.yaml` line 6: `download_referid`, `product`, `package` — all unprefixed.

**Recommendation:** Fix the offending variables in `davinci_resolve` (prefix with `_davinci_` or `davinci_`) and remove the global skip rule, or narrow it to
specific files using `noqa` inline comments.
**Effort:** Medium (finding and fixing all unprefixed vars).
**Priority:** Medium

---

### CI-5 — No `molecule` or role-level unit tests

**Why it matters:** There is no role-level testing (Molecule, testinfra, or similar). The functional CI tests run the entire playbook, which makes it difficult
to isolate which role is broken when a test fails. Complex roles like `kvm`, `davinci_resolve`, and `mangohud` particularly benefit from isolated tests.

**Evidence:** No `molecule/` directories in any role; no test framework in `requirements.yml`.

**Recommendation:** This is a long-term investment. Start with the two most complex roles: add Molecule scenarios for `trezor_suite` (already well-structured)
and `orcaslicer`. Use the `delegated` driver since this targets localhost.
**Effort:** High.
**Priority:** Low (nice-to-have)

---

### CI-6 — Pre-commit `prettier-yaml` uses `--write` (auto-fixes) but `yamllint` runs separately

**Why it matters:** Prettier reformats YAML files on commit. yamllint then lints them. If Prettier introduces a style that yamllint rejects (e.g. line length),
the CI will fail. Currently both tools run, but since Prettier writes first and yamllint is `needs: [actionlint, prettier]` in CI, a mismatch could cause
confusing failures.

**Evidence:** `.pre-commit-config.yaml` lines 33–37 (prettier with `--write`); `.github/workflows/ci.yaml` line 361 (`yamllint: needs: [actionlint, prettier]`).

**Recommendation:** Ensure `.yamllint.yaml` ignores any style rules that Prettier handles (line-length is already skipped in `.ansible-lint`; check
`.yamllint.yaml` for any Prettier-incompatible rules).
**Effort:** Low.
**Priority:** Low

---

## 8. Documentation and Onboarding

### DOC-1 — README has no "Contributing / Adapting" section for new users

**Why it matters:** The README says "it can be easily adapted to different setups" but gives no guidance on what to customise beyond enabling/disabling roles.
New adopters don't know they need to change DaVinci registration data, git config, locale/timezone, mangohud version, etc.

**Evidence:** `README.md` — no section on customisation beyond toggle flags.

**Recommendation:** Add a "Customising for your setup" section listing: locale/timezone (`common` defaults), DaVinci credentials, git identity, any tool
versions. Even 5 bullet points would significantly improve onboarding.
**Effort:** Low.
**Priority:** Medium

---

### DOC-2 — `TODO.md` should become GitHub Issues (or be structured)

**Why it matters:** `TODO.md` is a flat file with 17 lines including bare URLs, single words (`pinta`, `calibre`), and one meta-task (
`Fix tags (see common.yaml)`). This is not useful to contributors or future-self. The `Fix tags` note is especially concerning — it implies a known issue that
isn't tracked anywhere useful.

**Evidence:** `TODO.md` entire file.

**Recommendation:** Convert each item to a GitHub Issue. Delete `TODO.md` or replace it with a pointer to the issue tracker.
**Effort:** Low.
**Priority:** Low

---

### DOC-3 — `kvm.md` and `DaVinciResolve.md` live inside role directories, inconsistently

**Why it matters:** Two roles have their own `.md` documentation files (`roles/kvm/kvm.md`, `roles/davinci_resolve/DaVinciResolve.md`). No other roles do. These
are not discoverable from `README.md` and are in inconsistent locations (one uses the role name, the other uses the product name).

**Evidence:** `roles/kvm/kvm.md`, `roles/davinci_resolve/DaVinciResolve.md`.

**Recommendation:** Either link these from `README.md` (under a "Detailed Role Documentation" section), or standardise to `roles/<role>/README.md` naming. If
they add real value, link them.
**Effort:** Trivial.
**Priority:** Low

---

### DOC-4 — No explanation of `generate-group-vars.sh` contract in README

**Why it matters:** The `all.yaml` file is auto-generated from role defaults. This is an unusual pattern that surprises contributors who try to edit `all.yaml`
directly, only to have their changes overwritten by the next pre-commit run.

**Evidence:** `all.yaml` line 1: `# Automatically generated from roles' defaults` — the only hint. The README mentions `group_vars/all.yaml` but never explains
it is generated.

**Recommendation:** Add a warning box or callout in the README: "Do not edit `inventory/group_vars/all.yaml` directly; it is auto-generated. To change defaults,
edit the role's `defaults/main.yaml` and run `make generate-group-vars`."
**Effort:** Trivial.
**Priority:** Medium

---

## 9. `.claude` Directory Review

### CL-1 — `.claude/settings.json` does not exist

**Why it matters:** The repository has a `.claude/` directory but it contains no `settings.json`. CLAUDE.local.md exists (correctly outside `.claude/`) but
there is no repository-level Claude Code settings file to encode tool permissions, allowed commands, or project-specific hooks.

**Evidence:** `ls .claude/` — directory exists but `settings.json` is absent.

**Recommendation:** Create a `.claude/settings.json` with at minimum `{}` to make the directory intentional. If specific permissions or hooks are needed (e.g.
allowing `make check` to run automatically), add them here.
**Effort:** Trivial.
**Priority:** Low

---

### CL-2 — `CLAUDE.local.md` rules are not enforced by any automated check

**Why it matters:** `CLAUDE.local.md` contains six critical rules (FQCN modules, vault usage, idempotency, etc.). These are instructions to Claude, not to a
linter. Some of them overlap with `ansible-lint` rules (FQCN is enforced by `fqcn[action-core]`), but others — like "never hardcode secrets" and "query current
state before mutating" — are not automatically validated.

**Evidence:** `CLAUDE.local.md` rules vs. `ansible-lint` ruleset — `vault_*` references are not enforced anywhere.

**Recommendation:** This is inherent to the AI-assistant workflow. No action required, but worth noting that the `var-naming[no-role-prefix]` skip in
`.ansible-lint` directly contradicts the "role-prefixed defaults" rule in `CLAUDE.local.md`. Consider aligning them.
**Effort:** Low (alignment of ansible-lint config).
**Priority:** Medium

---

### CL-3 — `CLAUDE.local.md` references `midclt` command convention but this is not an TrueNAS repo

**Why it matters:** The rule "For `midclt` calls, use `ansible.builtin.command`" is TrueNAS-specific (`midclt` is the TrueNAS middleware client). This codebase
has no TrueNAS code and no `midclt` calls. This rule is cargo-culted from a different project's CLAUDE.local.md.

**Evidence:** No `midclt` references anywhere in the repo; `CLAUDE.local.md` line: "For `midclt` calls, use `ansible.builtin.command`…"

**Recommendation:** Remove or generalise this rule to "prefer `ansible.builtin.command` over `ansible.builtin.shell` unless shell features are required."
**Effort:** Trivial.
**Priority:** Low

---

## 10. Quick Wins

These are changes that take less than 30 minutes and have immediate value:

| #     | Action                                                                                                                                                                                                       | File(s)                                                                                | Effort                           |
|-------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|----------------------------------|
| QW-1  | Swap gamemode/gparted variable names in defaults                                                                                                                                                             | `roles/gamemode/defaults/main.yaml`, `roles/gparted/defaults/main.yaml`                | 2 min                            |
| QW-2  | Fix CI test file paths (`all.yml` → `inventory/group_vars/all.yaml`, `ubuntu-setup.yml` → `playbooks/ubuntu-setup.yaml`)                                                                                     | `.github/workflows/ubuntu-test.yaml`                                                   | 2 min                            |
| QW-3  | Fix `gaming.yaml` playbook name from `Ubuntu Work Playbook` to `Ubuntu Gaming Playbook`                                                                                                                      | `playbooks/gaming.yaml`                                                                | 1 min                            |
| QW-4  | Remove trailing space from `mangohud.version: "v0.8.1 "`                                                                                                                                                     | `roles/mangohud/defaults/main.yaml`                                                    | 1 min                            |
| QW-5  | Add `tags: development` to `development` role in `development.yaml`                                                                                                                                          | `playbooks/development.yaml`                                                           | 1 min                            |
| QW-6  | Add `tags: desktop` to `desktop` role in `desktop.yaml`                                                                                                                                                      | `playbooks/desktop.yaml`                                                               | 1 min                            |
| QW-7  | Remove hardcoded Google Analytics cookie from DaVinci role                                                                                                                                                   | `roles/davinci_resolve/tasks/main.yaml` line 84                                        | 2 min                            |
| QW-8  | Rename `lspci_output` register to `lspci_output_nvidia` for consistency                                                                                                                                      | `playbooks/tasks/pre_tasks.yaml`                                                       | 2 min                            |
| QW-9  | Add `# Do not edit directly — generated by make generate-group-vars` comment to `all.yaml` header in `generate-group-vars.sh` (it already has one, but make it more prominent / link to the Makefile target) | `generate-group-vars.sh`                                                               | 5 min                            |
| QW-10 | Add `pull_request:` trigger to `ubuntu-test.yaml` with `paths:` filter                                                                                                                                       | `.github/workflows/ubuntu-test.yaml`                                                   | 10 min                           |
| QW-11 | Fix `has_nvidia_gpu` to use `stdout \| length > 0` instead of `rc` check                                                                                                                                    | `playbooks/tasks/pre_tasks.yaml`                                                       | 2 min                            |
| QW-12 | Disable one of `orcaslicer_enabled` or `orcaslicer_flatpak_enabled` by default                                                                                                                               | `roles/orcaslicer/defaults/main.yaml` or `roles/orcaslicer_flatpak/defaults/main.yaml` | 2 min                            |
| QW-13 | Replace `midclt` rule in `CLAUDE.local.md` with general `command` vs `shell` guidance                                                                                                                        | `CLAUDE.local.md`                                                                      | 5 min                            |
| QW-14 | Add DaVinci registration data comment and `vault.yaml.example`                                                                                                                                               | `inventory/group_vars/all.yaml`, new file                                              | 15 min                           |

---

## 11. Longer-Term Refactors

### LT-1 — Refactor `gsettings` role to use `community.general.dconf` module

Estimated effort: 2–4 hours. Reduces 160 lines to ~30. Eliminates all `DBUS_SESSION_BUS_ADDRESS` environment blocks. The `community.general` collection is
already in `requirements.yml`.

---

### LT-2 — Split `davinci_resolve/tasks/main.yaml` into subtask files

Estimated effort: 1–2 hours (mechanical refactor). Reduces the single 575-line file to 5 focused files of ~80–120 lines each. Follow the `kvm` role pattern.

---

### LT-3 — Add version-pinning idempotency to `orcaslicer`

Estimated effort: 1 hour. Write a version marker file at install time, read it on subsequent runs, compare to `orcaslicer_appimage.version`, and skip if
unchanged. Model after `trezor_suite`.

---

### LT-4 — Introduce `ansible-vault` for personal credentials

Estimated effort: 2–3 hours (initial setup). Create a vault file for DaVinci registration data, git user config, and any other PII. Document the vault password
pattern in README. This is optional for a personal project but important if the repo is used by others.

---

### LT-5 — Add Molecule tests for `trezor_suite` and `orcaslicer`

Estimated effort: 4–8 hours per role. These are the most complex non-trivial roles and the most likely to break on version bumps. Even a converge + idempotency
test without assertions provides significant value.

---

### LT-6 — Standardise variable style (dict vs flat) across all roles

Estimated effort: 3–5 hours. Migrate `nodejs`, `kvm_gpu_passthrough`, and any other outliers to the dict pattern used by `orcaslicer`, `trezor_suite`,
`virtualbox`. This is a breaking change for anyone overriding variables in host_vars.

---

### LT-7 — Make `common` role's `apt upgrade` opt-in

Estimated effort: 30 minutes. Add `common_upgrade_packages: false` default and gate the upgrade task on it. Prevents unintended package upgrades on re-runs.

---

## 12. Consistency and Style Audit

### Naming inconsistencies

| Location                                                           | Issue                              |
|--------------------------------------------------------------------|------------------------------------|
| `gaming.yaml` → `name: Ubuntu Work Playbook`                       | Should be `Ubuntu Gaming Playbook` |
| `gparted/defaults/main.yaml` → `gamemode_enabled`                  | Should be `gparted_enabled`        |
| `gamemode/defaults/main.yaml` → `gparted_enabled`                  | Should be `gamemode_enabled`       |
| `nodejs` flat vars vs dict vars elsewhere                          | Inconsistent variable structure    |
| `lspci_output` (NVIDIA) vs `lspci_output_amd`/`lspci_output_intel` | Inconsistent register naming       |

### Patterns that exist implicitly but should be documented

- **Internal facts use `_` prefix** (`_trezor_needs_install`, `_orcaslicer_ai_do_install`) — good pattern, should be documented in CLAUDE.local.md as the
  convention.
- **`changed_when: false` on read tasks, `changed_when: true` on write tasks** — well-applied but implicit; one sentence in CLAUDE.local.md would make it
  explicit.
- **State-machine pattern** (check → set_fact → conditional block) — used in `trezor_suite` and `orcaslicer` but not in `davinci_resolve` or `mangohud`. Make it
  the explicit standard.

### Roles that are in wrong playbooks

- `filezilla` is in `development.yaml` but is a file transfer tool (arguably desktop); unlikely to matter in practice.
- `discord` is in `gaming.yaml` but is a communication tool; `gaming.yaml` is named "Work Playbook" internally anyway, adding to the confusion.
- `vlc` appears both as a `desktop.packages` list item and as a standalone role — it may be installed twice. Check whether the `common.packages` → `vlc` entry
  in `desktop:` dict conflicts with the standalone `vlc` role.

**Evidence:** `inventory/group_vars/all.yaml` lines 103 and 375 — `vlc` in `desktop.packages` list AND `vlc_enabled: true` as a standalone role.

---

## 13. Strengths (brief)

- **FQCN discipline**: All module calls use fully-qualified names throughout — no exceptions found.
- **`trezor_suite` role**: Exemplary GPG signature verification, state-machine pattern, flush_handlers usage, proper error messages.
- **`orcaslicer` role**: Clean GitHub API consumption, good assertion at the top, proper `_ai_` prefix on all internal facts.
- **CI pipeline**: Reviewdog inline PR comments, pinned tool versions, concurrency cancellation — above-average for a personal project.
- **`generate-group-vars` feedback loop**: Pre-commit hook + CI check ensures `all.yaml` is always in sync with role defaults. Elegant self-maintaining
  mechanism.
- **`pre_tasks.yaml` block with `tags: always`**: Ensures facts are always gathered even when running with specific tags.
- **`deb822_repository` module**: All repo-based roles use the modern deb822 format, not legacy `apt_key`/`apt_repository` which are deprecated.

---

## 14. Prioritised Action Plan

### Do First (bugs and high-impact fixes)

1. **QW-1**: Swap `gamemode`/`gparted` variable names — active bug causing wrong enable/disable behaviour
2. **QW-2**: Fix CI test file paths — second job is silently broken
3. **QW-3**: Fix `gaming.yaml` playbook `name:` field
4. **QW-4**: Remove trailing space from `mangohud.version`
5. **QW-5 + QW-6**: Add missing role tags in `development.yaml` and `desktop.yaml`
6. **SEC-1 + QW-14**: Add PII warning comment to DaVinci defaults, add `vault.yaml.example`

After these six items, regenerate `inventory/group_vars/all.yaml` with `make generate-group-vars` and verify the CI passes.

---

### Do Next (important quality improvements)

1. **A-3**: Add idempotency check to `mangohud` (prevent unnecessary full rebuilds)
2. **A-8**: Add version-check idempotency to `davinci_resolve`
3. **A-9**: Add version marker to `orcaslicer` (detect version drift)
4. **A-10**: Disable one of `orcaslicer`/`orcaslicer_flatpak` by default (or document the dual-install)
5. **CI-2**: Add `pull_request:` trigger to `ubuntu-test.yaml` with role/playbook path filter
6. **CI-4**: Prefix unprefixed vars in `davinci_resolve`, then remove global `var-naming[no-role-prefix]` skip
7. **DOC-4**: Add `all.yaml` auto-generation notice to README
8. **DOC-1**: Add "Customising for your setup" section to README
9. **CL-2/CL-3**: Update `CLAUDE.local.md` — remove `midclt` reference, document `_` prefix convention

---

### Nice to Have Later

1. **A-1**: Refactor `gsettings` to use `community.general.dconf` or loop-based approach
2. **A-2**: Split `davinci_resolve/tasks/main.yaml` into subtask files
3. **LT-4**: Introduce `ansible-vault` for PII fields
4. **LT-5**: Add Molecule tests for `trezor_suite` and `orcaslicer`
5. **LT-6**: Standardise variable style (`nodejs` dict migration)
6. **LT-7**: Make `common` apt upgrade opt-in
7. **S-2 / DOC-2**: Convert `TODO.md` to GitHub Issues
8. **DOC-3**: Link or standardise `kvm.md` / `DaVinciResolve.md`
9. **S-5**: Sort `generate-group-vars.sh` loop output explicitly for stability
10. **A-7**: Gate `apt upgrade` behind a variable flag

---

*End of document. All recommendations are based on direct file reads. No changes have been made to the codebase.*
