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
        }
    }
}
