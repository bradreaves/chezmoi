# Device applications after reinstall

## Logitech

The macOS desktop Brewfile includes `cask "logi-options+"`. Install it through
the normal `brew bundle` step. This uses the supported installer; do not copy
old background-service app bundles or launch agents onto the fresh system.
Follow the installer's reboot instructions and grant the macOS permissions it
requests for the supported devices you use.

If device settings were backed up through a Logitech account, sign in and
restore the appropriate Mac backup. Verify button/key mappings, scrolling and
any application-specific profiles against the physical device. Account backup
availability has not been verified during this audit. Local Options+ data and
preferences still need a separate recovery decision; their presence is not
proof of a complete cloud backup.

Logitech use was confirmed. Loupedeck-specific software was not selected by
that decision; do not install it solely because an old plugin service exists.

- [Homebrew cask](https://formulae.brew.sh/cask/logi-options+)
- [Logitech installer and supported devices](https://www.logitech.com/en-us/software/logi-options-plus)
- [Logitech settings backup and recovery](https://hub.sync.logitech.com/k620/post/backup-device-settings-to-the-cloud-in-logitech-options-B0vjYROUUBfnL5W)

## Epson ET-2720

Epson use was confirmed, and this laptop has ET-2720 printer presets plus
Epson Scan 2 and scanner-device preferences. Download the printer/scanner
software from the [ET-2720 support page](https://epson.com/Support/Printers/All-In-Ones/ET-Series/Epson-ET-2720/s/SPT_C11CH42201),
selecting the fresh system's macOS version. Use the offered printer driver
and Epson Scan 2/scanner utility for that OS. A fixed package URL or copied
old driver is not part of this restore.

Add the printer/scanner and verify a print and a scan. Compare needed scan
settings and printer presets with the separately preserved settings before
considering device recovery complete. The existing Epson preferences/presets
have been identified, but their backup and fresh-OS compatibility are not yet
verified. ScanSnap Home is a separate, already selected application.

## Applications excluded by the user

Do not include these in the fresh-install application selection:

- Cricut Design Space
- Artiphon Connect
- Keyspan Serial Assistant
- Unsloth Studio
- GoTo
- Discord Safari web app
- NDSS Mattermost Safari web app
- Local Hermes

These selections do not authorize deleting local projects, models or settings.
Unique data must receive its own keep/archive/discard decision before the wipe.
Existing application installations were left unchanged during this work.

## Validation status

This checklist and the Brewfile entry preserve the approved install choices.
The Logitech cask definition and Epson model-support page were checked. No
installer, driver, reboot or device test was run on the current laptop, and
the full fresh-OS restore has not been tested.
