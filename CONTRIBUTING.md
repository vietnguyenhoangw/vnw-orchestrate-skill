# Contributing

`scripts/validate.sh` enforces the plugin's core invariants. Run it before
pushing: `bash scripts/validate.sh`.

Invariants it checks:

- SKILL.md frontmatter: valid YAML, exactly `name`/`description`,
  `name == "orchestrate"`, one-line description mentioning orchestrate,
  delegate, Haiku, Sonnet.
- SKILL.md body keeps: the built-in `Agent` tool, the Cheap/Fast and
  Deep-Reasoning tier labels, the Classification Checklist, the
  never-launch-Haiku-for-judgment rule, the Concurrency Cap section, and
  `$ARGUMENTS`.
- `.claude-plugin/plugin.json`: valid JSON, `name == "orchestrate"`, semver
  `version`.
- `install.sh`: valid syntax/lint, copies `skills/orchestrate` into
  `~/.claude/skills/orchestrate` locally, and fails cleanly when piped
  without a local checkout.
- `README.md`: keeps `## Install`/`## Usage`/`## Troubleshooting` and
  mentions `/orchestrate`.
- `.release-please-manifest.json`: `.["."]` matches plugin.json `.version`.

PRs need the `validate` check green before merge.

Commits must follow [Conventional Commits](https://www.conventionalcommits.org/):
`feat:` bumps minor, `fix:`/`docs:`/`chore:` bump patch, `feat!:` or a
`BREAKING CHANGE` footer bumps major. release-please opens/updates a
`chore(main): release X.Y.Z` PR from these commits; merging it bumps
`.claude-plugin/plugin.json`, `version.txt`, tags `vX.Y.Z`, and publishes the
GitHub Release. Do not hand-edit versions.
