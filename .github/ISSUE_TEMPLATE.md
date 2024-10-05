
### Step 1: Are you in the right place?
- [ ] I have verified there are no duplicate active or recent bugs, questions, or requests.
- [ ] I have verified that I am using the latest version of the playbook.

### Step 2: Describe your environment
- Ansible version: `?`
- Operating System: `?`
- Ansible playbook: `?`
- Role (if applicable): `?`

### Step 3: Describe the problem:

#### Steps to reproduce:
1. _____
2. _____
3. _____

#### Observed Results:
<!-- What happened? This could be a description, error message, or log output. -->
*

#### Expected Results:
<!-- What did you expect to happen? -->
*

#### Relevant Code:
<!-- Please wrap code with correct syntax highlighting. -->
```yaml
- name: Example task
  hosts: localhost
  tasks:
    - name: Print Hello World
      debug:
        msg: "Hello, world!"
```

#### Error/Log Output:
<!-- If you are getting an error during playbook execution, paste the output here. Please wrap the logs or error messages with Bash syntax highlighting (it makes them look better). -->
```bash
TASK [example : Print Hello World] ********************************************
fatal: [localhost]: FAILED! => {"changed": false, "msg": "An example error"}
```

<!-- Adding pictures/screenshots/videos of the expected/actual result is always helpful -->
