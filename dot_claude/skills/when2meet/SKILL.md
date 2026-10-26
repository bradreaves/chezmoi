---
name: when2meet
description: Fill in a when2meet availability grid from the user's Google Calendar using Playwright. Use when the user gives a when2meet.com link, or asks to "fill in this when2meet" or "mark my availability".
---

# Fill a when2meet from Google Calendar

The user logs in themselves. Never ask for or type credentials.

## Workflow

1. Load tools in one ToolSearch call: the Playwright tools (`browser_navigate`, `browser_snapshot`, `browser_run_code_unsafe`, `browser_take_screenshot`) and the Google Calendar tools (`list_events`).
2. Navigate to the when2meet URL. Tell the user to log in and dismiss the consent dialog, then wait for them to confirm. Do not mark anything before they confirm.
3. Read the grid range and timezone (see "Inspect the grid").
4. Fetch events for that date range with `list_events` (`orderBy: startTime`, `pageSize: 250`, no timeZone unless the user states one). Ignore events with `availability: AVAILABILITY_FREE` or `transparency: transparent` (e.g. all-day birthdays).
5. Confirm the rules with the user in one message, showing the free windows you plan to mark. Ask only about things you cannot infer:
   - Earliest start and latest end of day they will accept.
   - Which recurring events are hard busy versus flexible (commute, class prep, open hours, focus blocks).
6. Fill the grid (see "Fill the grid"), screenshot, and summarize what was marked.

Known preferences from past runs (confirm, do not assume): earliest start 10:00 AM; Dept. Open Hours, class meetings (CSC 574), and external meetings are busy; "Class Prep/Work" is flexible; commute events end by 9:45 AM so they never matter after the 10:00 AM start.

## Inspect the grid

Slots are `div#YouTime<unix-seconds>` inside `#YouGrid`, with `data-time`, `data-col`, `data-row`. Each is 15 minutes. Unselected slots are pink, selected are green. Gaps in `data-time` between columns are days skipped by the event.

```js
() => {
  const els = [...document.querySelectorAll('#YouGrid [id^=YouTime]')];
  const t = els.map(e => +e.dataset.time);
  const f = s => new Date(s*1000).toLocaleString('en-US', {timeZone: 'America/New_York'});
  return {min: f(Math.min(...t)), max: f(Math.max(...t)), n: els.length};
}
```

Check the page's timezone selector (default is the browser's, usually America/New_York) and compare it to the calendar timezone.

## Fill the grid

Slots toggle on mousedown plus mouseup dispatched on each element. Saving is immediate, so there is no submit button. Dispatch one slot at a time with a short delay (60 ms worked for ~370 slots). Compute each slot's local weekday and minutes with `Intl.DateTimeFormat` in the calendar timezone, then decide whether it is free. Only toggle slots that are currently unselected (pink) so a rerun does not undo earlier work.

```js
async (page) => page.evaluate(async () => {
  const fmt = new Intl.DateTimeFormat('en-US', {timeZone: 'America/New_York', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', hourCycle: 'h23', weekday: 'short'});
  const isFree = (weekday, day, minutes) => { /* build from calendar events and user rules */ };
  const want = [];
  for (const el of document.querySelectorAll('#YouGrid [id^=YouTime]')) {
    const p = Object.fromEntries(fmt.formatToParts(new Date(+el.dataset.time*1000)).map(x => [x.type, x.value]));
    const selected = /rgb\(51, ?153, ?0\)|#339900/i.test(getComputedStyle(el).backgroundColor) || el.style.background.includes('rgb(51, 153, 0)');
    if (!selected && isFree(p.weekday, p.month + '/' + p.day, +p.hour*60 + +p.minute)) want.push(el);
  }
  for (const el of want) {
    const o = {bubbles: true, cancelable: true, view: window};
    el.dispatchEvent(new MouseEvent('mousedown', o));
    el.dispatchEvent(new MouseEvent('mouseup', o));
    await new Promise(r => setTimeout(r, 60));
  }
  return want.length;
})
```

Verify the selected-color test against one slot first (read its computed background before and after a toggle), since the green value may differ.

## Verify and report

Take a screenshot with `browser_take_screenshot`. The user's grid ("<name>'s Availability") should be green exactly where free; the Group grid on the right should darken. If the grid extends past the viewport, scroll or resize and check the remaining weeks. Report the rules used in a compact table (days versus free windows) and note any events treated as busy or flexible.

## Notes

- Playwright MCP runs its own browser, so the user must log in there, not in their normal Chrome.
- Do not trigger the page's alert/confirm dialogs.
- Clearing a mistake: toggle the wrongly selected slots again the same way.
