# NotchNookClone (CLI-only, macOS 14+)

SwiftUI clone of a system-wide Now Playing pill (NotchNook-style) without Xcode GUI.

## Build
```bash
xcode-select --install   # if needed
make run                 # builds, signs ad-hoc (with entitlements), and opens the .app
```

## Notes
- Uses private `MediaRemote.framework` → personal use only.
- Requires disabling Library Validation (done via entitlements + ad-hoc codesign).
- Shows metadata from apps/sites exposing Media Session (e.g., YouTube in Chrome).

## Repo init
```bash
git init
git add .
git commit -m "Initial commit: CLI NotchNook clone"
git branch -M main
git remote add origin <YOUR_GITHUB_REPO_URL>
git push -u origin main
```
