# orchestrate

A Claude Code skill that turns the current session into a lead orchestrator:
it routes each atomic unit of work to the cheapest capable tier — a Haiku
subagent via the built-in `Agent` tool for Cheap/Fast work, or itself
(Sonnet) for anything that needs real judgment — instead of doing everything
on one model.

[![License: MIT](https://img.shields.io/github/license/vietnguyenhoangw/vnw-orchestrate-skill)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/vietnguyenhoangw/vnw-orchestrate-skill)](https://github.com/vietnguyenhoangw/vnw-orchestrate-skill/releases)

> [!NOTE]
> This is a personal/internal fork of
> [yanmad27/my-orchestrate-skill](https://github.com/yanmad27/my-orchestrate-skill).
> All credit for the original lead-orchestrator / cost-tiered-delegation idea
> goes to **[@yanmad27](https://github.com/yanmad27)** — see [Credits](#credits).
> This fork reworks the same idea for a lighter, budget-conscious setup: it
> drops the [Paseo](https://paseo.sh) dependency and runs entirely on Claude
> Code's native `Agent` tool instead, for internal use.

## Contents

- [Quick start](#quick-start)
- [Requirements](#requirements)
- [Install](#install)
- [Upgrade](#upgrade)
- [Troubleshooting](#troubleshooting)
- [Usage](#usage)
- [Credits](#credits)

## Quick start

```
/plugin marketplace add vietnguyenhoangw/vnw-orchestrate-skill
/plugin install orchestrate@vnw-orchestrate-skill
```

Run `/orchestrate <task>` in any Claude Code session.

> [!NOTE]
> The two `/plugin` commands must run as separate turns in Claude Code.
> See [Install](#install) for the clone/manual path.

## Requirements

- Claude Code, with the built-in `Agent` tool available (it is on by default).

No third-party daemon, MCP server, or config merge is required — the skill
only uses Claude Code's native `Agent` tool with its per-call `model`
override.

## Install

### Option A: plugin marketplace

Run these as two separate commands in Claude Code (they cannot be combined
in one turn):

1. Add the marketplace:

   ```
   /plugin marketplace add vietnguyenhoangw/vnw-orchestrate-skill
   ```

2. Install the plugin:

   ```
   /plugin install orchestrate@vnw-orchestrate-skill
   ```

### Option B: clone + script

```sh
git clone https://github.com/vietnguyenhoangw/vnw-orchestrate-skill.git
cd vnw-orchestrate-skill
./install.sh
```

This copies `skills/orchestrate` to `~/.claude/skills/orchestrate`.

## Upgrade

### Plugin (Option A)

```
/plugin marketplace update vnw-orchestrate-skill
```

Then, in a terminal (not inside a Claude Code session):

```sh
claude plugin update orchestrate@vnw-orchestrate-skill
```

If you have a session open, run `/reload-plugins` there afterward to load
the change. Auto-update is off by default for third-party marketplaces like
this one. To enable it: `/plugin` → **Marketplaces** → select
`vnw-orchestrate-skill` → **Enable auto-update**.

### Clone (Option B)

```sh
cd vnw-orchestrate-skill && git pull && ./install.sh
```

**Check version:** `/plugin` → **Installed** tab, or
`claude plugin details orchestrate@vnw-orchestrate-skill`. Compare with the
[releases page](https://github.com/vietnguyenhoangw/vnw-orchestrate-skill/releases).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `/orchestrate` doesn't seem to route anything to Haiku | Check that the session actually invoked the skill (`/orchestrate <task>` or an explicit delegation phrase) — it is manual/opt-in only, it never auto-runs. |
| Everything gets handled directly, nothing gets delegated | That's expected for reuse/breadth-limited tasks — see the Classification Checklist in `skills/orchestrate/SKILL.md`. Delegation is the default only when a task actually clears that checklist. |
| Skill not found after install | Re-run `/plugin install orchestrate@vnw-orchestrate-skill`, or for the clone path, re-run `./install.sh` and restart the session. |

## Usage

### Invoke

**Slash command:**
```
/orchestrate <task>
```

**Auto-trigger:** the skill activates when you ask for delegation in natural
language:
- `orchestrate this bug fix`
- `giao cho worker fix cái bug này`
- `delegate the refactor across agents`
- `spawn subagents to investigate why CI fails`

### Examples

| Task | Routed to |
|---|---|
| `/orchestrate rename UserSvc to UserService across the repo` | **Haiku** (mechanical refactor) |
| `/orchestrate find every place we call the legacy payment API` | **Haiku** (unbounded search) |
| `/orchestrate add rate limiting to the POST /login endpoint` | **You** (Deep-Reasoning: design + implementation) |
| `/orchestrate why does CI keep timing out on main?` | **You** (root-cause investigation) |
| `/orchestrate summarize these 5 log files into one report` | **Haiku** (read/summarize, batch) |

### What happens

1. The Leader (this session) receives the task and runs the Classification
   Checklist (reuse → breadth → batch → output-size) against it.
2. No match → the Leader handles it directly (Deep-Reasoning tier). No
   Sonnet subagent is ever spawned — that would just be a same-capability
   copy of the Leader with zero benefit.
3. A match → the Leader delegates to a Haiku subagent via the `Agent` tool,
   with a sharp objective, minimal context, constraints, output format, and
   acceptance criteria. At most 2 Haiku subagents run at once, and at most 1
   of those is a write-type task.
4. The Leader reviews every delegated result itself before using it — depth
   scaled to confidence and stakes, never skipped, never a full re-read by
   default.
5. A capability-based failure after one sharper-spec retry escalates back to
   the Leader directly — there's no tier above Sonnet to escalate further to.
6. The Leader reports outcome, files changed, and anything unresolved.

### Tips

- **Give acceptance criteria:** "rename to snake_case and update all
  imports" beats "refactor this". The Haiku subagent sees none of this
  conversation.
- **Say "read-only"** if you want an audit, investigation, or review without
  file changes — delegated work defaults to read-only anyway.
- **Mention constraints:** if a file or area must not be touched, state it
  in the task.
- **Don't expect a mandatory review subagent:** the Leader reviews delegated
  work itself; a second reviewer is only spun up for explicitly high-stakes
  work (security, auth, migrations, irreversible ops).

## Credits

This project started as a fork of
[yanmad27/my-orchestrate-skill](https://github.com/yanmad27/my-orchestrate-skill)
by **[@yanmad27](https://github.com/yanmad27)**. The core idea — a lead
session that never implements directly, routes every unit of work to the
cheapest capable model tier, and reviews before reporting back — is entirely
theirs; full credit for the original design and skill structure goes to the
original author.

This fork (`vnw-orchestrate-skill`) reimplements that idea for personal,
budget-conscious use: the upstream version runs on top of
[Paseo](https://paseo.sh) (a separate daemon with its own `create_agent` MCP
tool, agent profiles, worktree management, and a watchdog/heartbeat
supervision loop). Since Claude Code's built-in `Agent` tool already accepts
a per-call `model` override, this fork drops the Paseo dependency entirely
and reimplements the same routing philosophy directly on top of it — fewer
moving parts, nothing extra to install or keep running, at the cost of
Paseo's multi-workspace/worktree and long-running-agent supervision features.
If you want the original, more feature-complete Paseo-integrated version,
use [the upstream repo](https://github.com/yanmad27/my-orchestrate-skill)
instead.
