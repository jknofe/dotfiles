#!/bin/sh
# Close the focused pane, but never the last pane of a tab (so the tab stays open).
# Run by herdr as a custom command; it provides the HERDR_* variables.
herdr="${HERDR_BIN_PATH:-herdr}"
tab="$HERDR_ACTIVE_TAB_ID"
pane="$HERDR_ACTIVE_PANE_ID"
[ -n "$tab" ] && [ -n "$pane" ] || exit 1

count=$("$herdr" pane list | grep -o "\"tab_id\":\"$tab\"" | wc -l)
if [ "$count" -gt 1 ]; then
  exec "$herdr" pane close "$pane"
fi
