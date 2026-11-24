# REDEx-Loop

Self-updating distribution for the REDEx-Loop injection console.

| File | Purpose |
| --- | --- |
| `REDEx-Loop.exe` | Current Windows x64 release. |
| `version.json` | Update manifest read by the launcher at startup. |
| `publish.ps1` | Copies a build, hashes it, rewrites the manifest and optionally pushes. |

## Update manifest

```json
{
  "version": "1.0.1",
  "url": "https://raw.githubusercontent.com/VINCENT-REDEX/ADB-Utils/main/REDEx-Loop/REDEx-Loop.exe",
  "sha256": "<sha256 of REDEx-Loop.exe>",
  "notes": "What changed in this build.",
  "mandatory": false
}
```

The launcher compares `version` with its embedded build version. A newer
version is downloaded to `%LOCALAPPDATA%\REDEx\REDEx-Loop.update.exe`, checked
as a 64-bit PE file, verified against `sha256`, then swapped into place. The
replacement process starts with `--updated` so only one console remains
visible.

## Publishing a build

```powershell
.\publish.ps1 -Version 1.0.2 -Notes "Faster injection and a cleaner console."
```

Publish from the `ADB-Utils` checkout so the manifest URL and the committed
binary stay in sync. Add `-Push` to commit and push the change:

```powershell
.\publish.ps1 -Version 1.0.2 -Notes "Faster injection." -Push
```

`-Exe` points at a build outside this folder. When omitted, the script uses
`$env:REDEXLOOP_BUILD` or an existing `REDEx-Loop.exe` beside the script.

## Runtime files

| Path | Purpose |
| --- | --- |
| `%LOCALAPPDATA%\REDEx\ADB` | Bootstrapped `adb.exe` and USB DLLs. |
| `%LOCALAPPDATA%\REDEx\AndKittyInjector` | Injector, downloaded only when injecting. |
| `%LOCALAPPDATA%\REDEx\libredex-loop.so` | Payload, downloaded only when injecting. |
| `%LOCALAPPDATA%\REDEx\redexloop_version.json` | Cached update manifest. |
| `%LOCALAPPDATA%\REDEx\REDEx-Loop.update.exe` | Verified update ready to install. |

The injector and payload are removed from the PC and the emulator after every
injection attempt.
