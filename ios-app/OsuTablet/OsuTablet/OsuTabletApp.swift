import SwiftUI

@main
struct OsuTabletApp: App {
    @StateObject private var connectionManager = ConnectionManager()
    @StateObject private var touchManager = TouchManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectionManager)
                .environmentObject(touchManager)
                .environmentObject(settingsManager)
                .statusBar(hidden: true)
                .persistentSystemOverlays(.hidden)
                .onAppear {
                    // Wire settings -> connection
                    connectionManager.attach(settingsManager: settingsManager)
                    // If connected, push current settings
                    if connectionManager.isConnected {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            connectionManager.sendSettings(settingsManager)
                        }
                    }
                }
        }
    }
}
