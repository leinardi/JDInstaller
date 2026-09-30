---
name: Bug report
about: Report a role or playbook that fails or does the wrong thing
title: "[Bug]: "
labels: ["bug"]
assignees: []
---
## Step 1: Are you in the right place?

* [ ] I have checked that there are no duplicate active or recent issues describing this problem.
* [ ] I am using the latest release of the playbook (or have tested on the `master` branch).

## Step 2: Describe your environment

* Ansible version (`ansible --version`): `?`
* Ubuntu version: `?`
* Playbook and tags (e.g. `make install TAGS=...`): `?`
* Role (if applicable): `?`

## Step 3: Describe the problem

### Steps to reproduce

1. ---
2. ---
3. ---

### Observed results

<!-- What happened? This could be a description, error message, or log output. -->

*

### Expected results

<!-- What did you expect to happen? -->

*

### Relevant configuration

<!-- The variables you changed in inventory/group_vars/all.yaml, if any. Never paste passwords or tokens. -->

```yaml
# Example (replace with your own)
docker_enabled: true
```

### Error / log output

<!-- If the playbook fails, paste the failing task's output here. -->

```text
TASK [example : Print Hello World] ********************************************
fatal: [localhost]: FAILED! => {"changed": false, "msg": "An example error"}
```

<!-- Adding screenshots or additional context is always helpful. -->
