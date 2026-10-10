// Fresh Startup Script - Created by Buffy
// This file runs automatically when Fresh starts.

// ── Verify config loaded correctly ──────────────────────────────────
const cfg = editor.getConfig() as Record<string, unknown>;
const theme = (cfg as any)?.theme;
if (theme) {
  editor.info(`Config loaded: theme=${theme}`);
}

// ── Done ─────────────────────────────────────────────────────────────
// All LSP and editor settings are in config.json.
// This script only runs runtime checks.
