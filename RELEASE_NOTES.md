# Release 1.0.3 🚀

### Added
- **Restart Action**: Added a dedicated "Restart" button for running VMs.
- **Action Feedback**: Visual loading state (spinner) on buttons while an action (Start/Stop/Restart) is processing.
- **Stability**: Implemented "Smart Polling" using Proxmox UPID. The UI now waits for the server to confirm the task is fully completed before unlocking, preventing "flickering" states.

### Changed
- **UI**: Increased main window width (380px -> 420px) to comfortably fit new action buttons.
- **Performance**: Optimized status verification loop to handle server latency gracefully.
