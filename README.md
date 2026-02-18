# UNDACTED + Epstein-Studio merger workspace

This repository contains an automated merge workflow that uses **Epstein-Studio as the base** and overlays configurable "core" functionality from **UNDACTED v2**.

Because this execution environment cannot reach GitHub directly, the merge is implemented as a reproducible script that you can run in a network-enabled environment:

```bash
./scripts/combine_apps.sh
```

## What the merger does

1. Clones Epstein-Studio and UNDACTED v2.
2. Copies Epstein-Studio into `build/merged-app` as the base project.
3. Overlays selected UNDACTED core paths into the merged project.
4. Generates a merge report with copied and skipped paths.

## Configuring "core" UNDACTED functions

The default overlay path list is in `config/undacted-core-paths.txt`.
Adjust this list based on the exact UNDACTED modules you consider core.

## Output

- Merged app: `build/merged-app`
- Report: `build/merge-report.md`
