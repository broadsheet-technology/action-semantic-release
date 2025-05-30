# pr-validate-and-merge

GitHub Action which automates validating, squashing, and merging pull requests using semantic-release. Ensures pull requests adhere to semantic-release commit message conventions and are rebased on the latest `main` branch before merging.

On successful validation, it uses semantic-release to bump the package version, commits the change with a formatted message, and merges the pull request with a squash commit based on the pull request title and semantic versioning.

e.g. `v0.1.12 - fix css on profile card (#34)`.

## Invoking the Action

Merges are initiated via an issue comment with `/merge`. Merges made using the GitHub GUI will not trigger this action.

## Inputs

| Name           | Description                      | Required |
| -------------- | -------------------------------- | -------- |
| `github-token` | GitHub token for authentication. | true     |

## Outputs

| Name              | Description                                             |
| ----------------- | ------------------------------------------------------- |
| `release-version` | The version of the release created by semantic-release. |

## Example Usage

```yaml
uses: broadsheet-technology/pr-validate-and-merge@v1
with:
  github-token: ${{ secrets.GITHUB_TOKEN }}
```
