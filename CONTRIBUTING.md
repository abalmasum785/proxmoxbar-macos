
# Contributing to ProxmoxBar

First off, thank you for considering contributing to ProxmoxBar! 🌟
It's people like you that make ProxmoxBar such a great tool for the community.

Following these guidelines helps to communicate that you respect the time of the developers managing and developing this open source project. In return, they should reciprocate that respect in addressing your issue, assessing changes, and helping you finalize your pull requests.

---

## 🛠 Development Setup

The project is built with Swift Package Manager (SPM).

### Prerequisites
- macOS 14.0 (Sonoma) or later.
- Xcode 16 or later.
- Swift 6.0.
- A Proxmox Server to test against.

### Run from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/ryzenixx/proxmoxbar-macos.git
   cd proxmoxbar-macos
   ```

2. **Open in Xcode**
   Double-click `Package.swift` or run:
   ```bash
   open Package.swift
   ```

3. **Build & Run**
   Select the `ProxmoxBar` target and press `Cmd+R`.

> **Important Note on Dev Mode**:
> When running locally via Xcode (`DEBUG` configuration), the app runs in **Developer Mode**.
> - **Visuals**: The interface is slightly darker/matte. This is normal behavior for inactive windows in debug mode.
> - **Updates**: The internal `UpdaterController` is disabled to prevent Sparkle errors.
> - **Assets**: Icons load from the local `Bundle.module` provided by SPM.

---

## 🐛 Found a Bug?

If you find a bug in the source code, you can help us by [submitting an issue](https://github.com/ryzenixx/proxmoxbar-macos/issues) to our GitHub Repository. Even better, you can submit a Pull Request with a fix.

**Please include:**
1. Your macOS version.
2. Your Proxmox VE version.
3. Steps to reproduce the issue.
4. Screenshots if applicable.

---

## 💡 Missing a Feature?

You can *request* a new feature by [submitting an issue](https://github.com/ryzenixx/proxmoxbar-macos/issues) to our GitHub Repository.
If you would like to *implement* a new feature, please submit an issue with a proposal for your work first, to be sure that we can use it.

---

## 📥 Submission Guidelines

### Submitting a Pull Request (PR)

1. **Fork** the repo on GitHub.
2. **Clone** the project to your own machine.
3. **Commit** changes to your own branch.
4. **Push** your work back up to your fork.
5. Submit a **Pull Request** so that we can review your changes.

NOTE: Be sure to merge the latest from "upstream" before making a pull request!

### Coding Standards

- Use **Swift 6** modern concurrency features (`async`/`await`) where possible.
- Layouts should be built with **SwiftUI**.
- Ensure `MenuBarView.swift` remains the clean, declarative entry point for the UI.
- Keep the "Native macOS Feel" in mind. Use system fonts, materials (`NSVisualEffectView`), and standard controls.

---

Thank you for your contributions! ❤️
