import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedMode: AppMode = .osuMode
    @State private var showSettings = false
    
    enum AppMode {
        case osuMode
        case screenMode
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if connectionManager.isConnected {
                switch selectedMode {
                case .osuMode:
                    OsuModeView()
                        .transition(.opacity)
                case .screenMode:
                    ScreenMirrorView()
                        .transition(.opacity)
                }
                
                // Mode switcher overlay
                VStack {
                    HStack(spacing: 20) {
                        ModeButton(
                            title: "OSU! Mode",
                            isSelected: selectedMode == .osuMode,
                            action: { withAnimation { selectedMode = .osuMode } }
                        )
                        
                        ModeButton(
                            title: "Screen Mode",
                            isSelected: selectedMode == .screenMode,
                            action: { withAnimation { selectedMode = .screenMode } }
                        )
                        
                        Spacer()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gear")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    Spacer()
                }
            } else {
                ConnectionView()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onChange(of: connectionManager.isConnected) { oldValue, newValue in
            if newValue {
                // Send settings to Windows when connection established
                print("📡 Connection established - sending settings")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    connectionManager.sendSettings(settingsManager)
                }
            }
        }
    }
}

struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.white.opacity(0.2))
                )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ConnectionManager())
        .environmentObject(TouchManager())
        .environmentObject(SettingsManager())
}
