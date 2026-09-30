# Security policy

## Supported versions

Only the latest release and the `master` branch get fixes. Released `vX.Y.Z` tags are immutable and are never re-pointed.

## Reporting a vulnerability

Report it privately through GitHub's
[private vulnerability reporting](https://github.com/leinardi/JDInstaller/security/advisories/new), not in a public issue or pull
request. Include the role or playbook, the Ubuntu version, and what an attacker could do.

This is a project maintained in spare time, so reports are handled on a best-effort basis. You will get an answer in the advisory,
and the fix, once released, is credited there unless you prefer otherwise.

## Scope

The playbook runs with administrator rights on the machine it sets up, so anything it downloads or trusts runs with them too. In
scope: a role that installs software or a signing key from a source it does not verify, that trusts a download over plain HTTP,
that leaves a file or setting more permissive than it needs to be, or that exposes a secret, and a workflow in this repository that
could publish something other than what was reviewed.

Out of scope: vulnerabilities in the software the roles install, which are reported to its vendor.
