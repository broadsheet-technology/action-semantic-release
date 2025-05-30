## Agents

- Prefer local implementation/scripting over importing other actions, unless the action is shipped by the tooling being used.
- Document any inputs in the README.md

## Original Prompt

```prompt
Implement pipeline dev op actions based on this workflow/spec

- use semantic-release
- all PRs will use semantic-release commit message format
- all merges will happen through git actions i.e. a issue comment with /merge (merge gui will be disabled)

upon the merge action; first, the following should be validated:

- the PR is currently rebased on top of current main head
- the PRs commits are all appropriate semantic-release

Ideally, these validations would also exist as PR validations in the GitHub GUI, but also enforced by the action

upon validation success:

- semantic-release should be used to bump the package version, and commit the change
- a commit message should be chosen by:
    1. taking the PR's title
    2. adding a prefix of vX.X.X (from semantic version number)
    3. postfixing the PR # parenthetically
    an example commit to main: v0.1.12 - fix css on profile card (#34)
- the PR should be squashed and merged to the target branch
- the branch should be deleted, and the PR closed as merged

Do not worry about and publishing tasks; the existing commit to main PR already handles publishing the application assuming the package version has been bumped
```
