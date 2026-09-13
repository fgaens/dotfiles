import fs from "node:fs"
import os from "node:os"
import path from "node:path"

const FEDNOT_ROOT = path.join(os.homedir(), "development", "fednot")
const OVERLAY = `{
  "preset": "fednot",
  "council": { "default_preset": "fednot" }
}
`

function isFednot(directory) {
  if (!directory) return false
  const dir = path.resolve(directory)
  return dir === FEDNOT_ROOT || dir.startsWith(FEDNOT_ROOT + path.sep)
}

function ensureFednotOverlay(directory) {
  const file = path.join(directory, ".opencode", "oh-my-opencode-slim.jsonc")
  try {
    if (fs.existsSync(file)) return
    fs.mkdirSync(path.dirname(file), { recursive: true })
    fs.writeFileSync(file, OVERLAY)
  } catch {
    // Overlay is best-effort; env preset still applies.
  }
}

export default async ({ directory }) => {
  const fednot = isFednot(directory)
  process.env.OH_MY_OPENCODE_SLIM_PRESET = fednot ? "fednot" : "personal"
  if (fednot) ensureFednotOverlay(directory)

  return {
    config(cfg) {
      if (fednot) return
      const current = Array.isArray(cfg.disabled_providers) ? cfg.disabled_providers : []
      cfg.disabled_providers = [...new Set([...current, "copilot"])]
    },
  }
}
