#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";

function authPath() {
  return path.join(process.env.CODEX_HOME || path.join(os.homedir(), ".codex"), "auth.json");
}

function readAuth() {
  const file = authPath();
  if (!fs.existsSync(file)) return null;
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return null;
  }
}

async function fetchUsage() {
  const auth = readAuth();
  const token = auth?.tokens?.access_token;
  if (!token) {
    return { ok: false, error: `No access token in ${authPath()}. Run \`codex login\` first.` };
  }
  const headers = { Authorization: `Bearer ${token}` };
  if (auth.tokens.account_id) headers["ChatGPT-Account-Id"] = auth.tokens.account_id;

  let response;
  try {
    response = await fetch(USAGE_URL, { headers });
  } catch (error) {
    return { ok: false, error: `Request failed: ${error.message}` };
  }
  if (response.status === 401) {
    return { ok: false, error: "Access token rejected (401). It has probably expired; run any `codex` command to refresh it, or `codex login`." };
  }
  if (!response.ok) {
    const body = await response.text().catch(() => "");
    return { ok: false, error: `Usage API returned ${response.status}${body ? `: ${body.slice(0, 200)}` : ""}` };
  }
  return { ok: true, data: await response.json() };
}

function windowLabel(seconds) {
  if (!seconds) return "Limit";
  if (seconds % 86400 === 0) return `${seconds / 86400}-day window`;
  if (seconds % 3600 === 0) return `${seconds / 3600}-hour window`;
  return `${Math.round(seconds / 60)}-minute window`;
}

function humanDuration(seconds) {
  if (typeof seconds !== "number" || seconds < 0) return null;
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const parts = [];
  if (d) parts.push(`${d}d`);
  if (h) parts.push(`${h}h`);
  if (m || parts.length === 0) parts.push(`${m}m`);
  return parts.join(" ");
}

function formatResetAt(epochSeconds) {
  if (typeof epochSeconds !== "number") return null;
  return new Date(epochSeconds * 1000).toLocaleString("en-GB", {
    weekday: "short", day: "numeric", month: "short", hour: "2-digit", minute: "2-digit"
  });
}

function renderWindow(prefix, window) {
  if (!window) return null;
  const used = typeof window.used_percent === "number" ? window.used_percent : null;
  const left = used == null ? "unknown" : `${Math.max(0, 100 - Math.round(used))}% left`;
  const bar = used == null ? "" : ` [${"#".repeat(Math.round(used / 5)).padEnd(20, ".")}]`;
  const resetIn = humanDuration(window.reset_after_seconds);
  const resetAt = formatResetAt(window.reset_at);
  const reset = resetIn ? ` — resets in ${resetIn}${resetAt ? ` (${resetAt})` : ""}` : "";
  return `${prefix}${windowLabel(window.limit_window_seconds)}: ${left}${bar}${reset}`;
}

function renderLimitGroup(lines, prefix, group) {
  if (!group) return;
  const flag = group.limit_reached ? "LIMIT REACHED — " : "";
  for (const window of [group.primary_window, group.secondary_window]) {
    const row = renderWindow(`${flag}${prefix}`, window);
    if (row) lines.push(row);
  }
}

function renderReport(report) {
  if (!report.ok) return `Codex usage error: ${report.error}\n`;
  const data = report.data ?? {};
  const lines = [];
  renderLimitGroup(lines, "", data.rate_limit);
  renderLimitGroup(lines, "code review ", data.code_review_rate_limit);
  if (lines.length === 0) lines.push("No rate limit windows reported.");
  return `${lines.join("\n")}\n`;
}

const json = process.argv.includes("--json");
const report = await fetchUsage();
if (json) {
  process.stdout.write(`${JSON.stringify(report.ok ? report.data : report, null, 2)}\n`);
} else {
  process.stdout.write(renderReport(report));
}
process.exitCode = report.ok ? 0 : 1;
