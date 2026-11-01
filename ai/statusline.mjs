// Claude Code status line: model and plan usage (5-hour and 7-day windows).
let raw = "";
process.stdin.on("data", (chunk) => (raw += chunk));
process.stdin.on("end", () => {
  const data = JSON.parse(raw || "{}");
  const parts = [data.model?.display_name ?? "Claude"];

  const fiveHour = data.rate_limits?.five_hour;
  if (fiveHour?.used_percentage != null) {
    const resets = new Date(fiveHour.resets_at * 1000).toLocaleTimeString([], {
      hour: "numeric",
      minute: "2-digit",
    });
    parts.push(`5h ${Math.round(fiveHour.used_percentage)}% (resets ${resets})`);
  }

  const sevenDay = data.rate_limits?.seven_day;
  if (sevenDay?.used_percentage != null) {
    parts.push(`7d ${Math.round(sevenDay.used_percentage)}%`);
  }

  console.log(parts.join(" · "));
});
