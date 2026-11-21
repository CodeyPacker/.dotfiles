// Copies a few keys of Herdr's shared.json between this repo and the app. Run by sync-config.
//   node sync-shared.mjs pull|push <repo file> <app file>
//
// shared.json mixes settings with state that only fits one computer (folder paths, space ids,
// timestamps, logins), so only the keys in KEYS are copied. The repo file holds just those keys.
//
// Herdr keeps shared state in memory and writes the file itself, so a pull while Herdr is open
// would be overwritten. A pull that has something to change waits until Herdr is closed.
import { copyFileSync, existsSync, readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";

/** The settings that should be the same on every computer. */
const KEYS = [
  "layout",
  "workspace.panels",
  "sidebar.width",
  "sidebar.collapsed",
  "agents.sort",
  "tickets.agent",
  "tickets.hiddenAgents",
];

const [mode, repoFile, appFile] = process.argv.slice(2);
if (!["pull", "push"].includes(mode) || !repoFile || !appFile) {
  console.error("Usage: node sync-shared.mjs pull|push <repo file> <app file>");
  process.exit(1);
}

const readJson = (path) => JSON.parse(readFileSync(path, "utf8"));
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);

/** True when a Herdr window is open, false when not, null when the herdr-app CLI is missing. */
function herdrIsOpen() {
  // SYNC_CONFIG_HERDR_OPEN=0 or 1 skips the check. It is for testing this script.
  if (process.env.SYNC_CONFIG_HERDR_OPEN === "0") return false;
  if (process.env.SYNC_CONFIG_HERDR_OPEN === "1") return true;
  try {
    execFileSync("herdr-app", ["status"], { stdio: "ignore", timeout: 15000 });
    return true;
  } catch (e) {
    return e.code === "ENOENT" ? null : false;
  }
}

if (mode === "push") {
  if (!existsSync(appFile)) {
    console.log(`Skipping shared.json, missing: ${appFile}`);
    process.exit(0);
  }
  const live = readJson(appFile);
  const kept = {};
  for (const key of KEYS) if (key in live) kept[key] = live[key];
  const text = JSON.stringify(kept, null, 2) + "\n";
  if (existsSync(repoFile) && readFileSync(repoFile, "utf8") === text) {
    console.log(`Already matches: ${repoFile}`);
  } else {
    writeFileSync(repoFile, text);
    console.log(`pushed shared.json (${Object.keys(kept).length} keys): ${appFile} -> ${repoFile}`);
  }
  process.exit(0);
}

if (!existsSync(repoFile)) {
  console.log(`Skipping shared.json, missing: ${repoFile}`);
  process.exit(0);
}
const wanted = readJson(repoFile);
const live = existsSync(appFile) ? readJson(appFile) : {};
const changed = KEYS.filter((key) => key in wanted && !same(live[key], wanted[key]));

if (changed.length === 0) {
  console.log(`Already matches: ${appFile}`);
  process.exit(0);
}

const open = herdrIsOpen();
if (open !== false) {
  const why = open ? "Herdr is open and would overwrite the change" : "herdr-app is not on PATH, so I cannot tell if Herdr is open";
  console.log(`Skipping shared.json: ${why}.`);
  console.log(`  Waiting to change: ${changed.join(", ")}`);
  console.log("  Close Herdr, then run: sync-config pull shared.json");
  process.exit(0);
}

if (existsSync(appFile)) copyFileSync(appFile, `${appFile}.bak-before-sync`);
for (const key of changed) live[key] = wanted[key];
// One line with no spaces, as Herdr writes it.
writeFileSync(appFile, JSON.stringify(live));
console.log(`pulled shared.json (${changed.join(", ")}): ${repoFile} -> ${appFile}`);
