import Foundation
import Sparkle
import SwiftUI

class UpdaterController: NSObject, ObservableObject, SPUUpdaterDelegate {
    private var updaterController: SPUStandardUpdaterController?
    
    @Published var canCheckForUpdates = false
    
    override init() {
        super.init()
        // Safety check: Sparkle requires a valid Bundle ID.
        // In local debug (swift run or xed), this might be missing.
        // If missing, we skip Sparkle initialization to prevent crash.
        if Bundle.main.bundleIdentifier != nil {
            self.updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: self, userDriverDelegate: nil)
        } else {
            print("⚠️ Bundle ID not found (Debug Mode). automatic updates disabled.")
        }
    }
    
    @MainActor
    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }
    
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        // Appcast loaded
    }
    
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        // Update found
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        // No update found
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        // Error handling
    }
}
