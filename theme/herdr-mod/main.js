// Theme: switches this computer between light and dark mode, then closes.
// Opened by a key (mod.open:theme-toggle). It runs the dotfiles' theme script, which saves
// the mode and sets Herdr's appearance, so the shell's `theme toggle` and this do the same thing.

import { View, div } from "gpui-kit";
import { exec, home, notify, props, closeOverlay, checking, window, theme } from "herdr";

/** The theme script for this platform, in the dotfiles repo. */
function themeCommand() {
  const dir = `${home()}/.dotfiles/theme`;
  return window().platform === "windows"
    ? ["pwsh", ["-NoProfile", "-File", `${dir}/theme.ps1`, "toggle"]]
    : ["sh", [`${dir}/theme.sh`, "toggle"]];
}

export default class ThemeToggle extends View {
  init(_props, cx) {
    this.text = "Switching theme…";
    if (checking()) return; // herdr-app check runs init for real: don't switch the theme then
    cx.spawn(async cx => {
      const [command, args] = themeCommand();
      const result = await exec(command, args).catch(e => ({ code: 1, stdout: "", stderr: String(e?.message ?? e) }));
      const mode = result.stdout.trim();
      if (result.code === 0 && (mode === "light" || mode === "dark")) {
        notify({ title: mode === "light" ? "Light mode" : "Dark mode", level: "success", timeout: 2000 });
      } else {
        notify({ title: "Could not switch the theme", body: result.stderr.trim() || `${command} exited with ${result.code}`, level: "error" });
      }
      const overlay = props()?.overlay;
      if (overlay) closeOverlay(overlay);
      cx.notify();
    });
  }

  render() {
    const t = theme();
    return div().size_full().flex().items_center().justify_center().p(12).text_size(12)
      .text_color(t.muted ?? t.foreground).child(this.text);
  }
}
