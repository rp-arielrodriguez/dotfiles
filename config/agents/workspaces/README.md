# Workspace Instructions

This directory documents the generic workspace-instruction mechanism. Keep the
mechanism in public dotfiles; keep private/company-specific instruction content in
a private location.

The installer reads workspace mappings from these files, if they exist:

1. `config/agents/workspaces/links.tsv`
2. `config/agents/workspaces/*.local.tsv`
3. `~/.config/agents/workspaces.tsv`

Use the local/private files for work or personal content that should not be
published.

## Format

Each non-comment line is tab-separated:

```text
<workspace-path>	<instruction-file>	<targets>
```

- `workspace-path`: directory where the instructions should be linked.
- `instruction-file`: source file containing the workspace instructions.
- `targets`: optional comma-separated filenames to create inside the workspace.
  Defaults to `AGENTS.md,CLAUDE.md`.

Both paths support a leading `~`.

## Example

```text
~/work/repos	~/.config/agents/workspaces/work/AGENTS.md	AGENTS.md,CLAUDE.md
~/personal	~/.config/agents/workspaces/personal/AGENTS.md	AGENTS.md
```

The instruction files themselves can live in a private repo cloned into
`~/.config/agents`, or in any other private path.
