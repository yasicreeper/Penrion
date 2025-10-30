import SwiftUI

@main
struct OsuTabletApp: App {
    @StateObject private var connectionManager = ConnectionManager()
    @StateObject private var touchManager = TouchManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var deviceStorage = DeviceStorageManager()
    @StateObject private var statsTracker = StatsTracker()
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Setup screen lock based on settings
        setupScreenLock()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectionManager)
                .environmentObject(touchManager)
                .environmentObject(settingsManager)
                .environmentObject(deviceStorage)
                .environmentObject(statsTracker)
                .environmentObject(themeManager)
                .statusBar(hidden: true)
                .persistentSystemOverlays(.hidden)
                .onAppear {
                    setupScreenLockObserver()
                }
        }
    }
    
    private func setupScreenLock() {
        // Initial screen lock setup
        let keepScreenOn = UserDefaults.standard.bool(forKey: "keepScreenOn")
        UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        print("🔒 Screen lock initialized: \(keepScreenOn ? "disabled" : "enabled")")
    }
    
    private func setupScreenLockObserver() {
        // Observe settings changes
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            let keepScreenOn = UserDefaults.standard.bool(forKey: "keepScreenOn")
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        }
    }
}
