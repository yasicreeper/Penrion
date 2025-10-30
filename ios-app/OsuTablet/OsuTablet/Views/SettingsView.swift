import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // ===== DISPLAY SECTION =====
                Section(header: Text("Display")) {
                    Toggle("Black Screen Mode", isOn: $settingsManager.blackScreenMode)
                    Toggle("Show Black Screen Button", isOn: $settingsManager.blackScreenButtonEnabled)
                    Toggle("Always-On Display", isOn: $settingsManager.alwaysOnDisplay)
                    Toggle("Fullscreen Mode", isOn: $settingsManager.fullscreenMode)
                    Toggle("Keep Screen On", isOn: $settingsManager.keepScreenOn)
                    
                    if settingsManager.alwaysOnDisplay {
                        VStack(alignment: .leading) {
                            Text("Inactivity Timeout: \(Int(settingsManager.inactivityTimeout / 60)) minutes")
                            Slider(value: $settingsManager.inactivityTimeout, in: 60...600, step: 60)
                        }
                    }
                }
                
                // ===== ACTIVE AREA SECTION =====
                Section(header: Text("Active Area")) {
                    VStack(alignment: .leading) {
                        Text("Width: \(Int(settingsManager.activeAreaWidth * 100))%")
                        Slider(value: $settingsManager.activeAreaWidth, in: 0.5...1.0)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Height: \(Int(settingsManager.activeAreaHeight * 100))%")
                        Slider(value: $settingsManager.activeAreaHeight, in: 0.5...1.0)
                    }
                    
                    Toggle("Show Area Outline", isOn: $settingsManager.showActiveArea)
                }
                
                // ===== OSU! MODE SECTION =====
                Section(header: Text("OSU! Mode")) {
                    Picker("Window Size Preset", selection: $settingsManager.osuWindowSize) {
                        ForEach([OsuWindowSize.tiny, .small, .medium, .large, .pro], id: \.self) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                    
                    Toggle("Pro Mode Settings", isOn: $settingsManager.osuProMode)
                        .help("Enables optimized settings for competitive play")
                }
                
                // ===== PRESSURE SENSITIVITY SECTION =====
                Section(header: Text("Pressure Sensitivity")) {
                    Picker("Curve Type", selection: $settingsManager.pressureCurve) {
                        Text("Linear").tag(PressureCurve.linear)
                        Text("Exponential").tag(PressureCurve.exponential)
                        Text("Logarithmic").tag(PressureCurve.logarithmic)
                        Text("Custom").tag(PressureCurve.custom)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Sensitivity: \(Int(settingsManager.pressureSensitivity * 100))%")
                        Slider(value: $settingsManager.pressureSensitivity, in: 0.5...2.0)
                    }
                }
                
                // ===== TOUCH FEEDBACK SECTION =====
                Section(header: Text("Touch Feedback")) {
                    Toggle("Visual Feedback", isOn: $settingsManager.visualFeedback)
                    Toggle("Haptic Feedback", isOn: $settingsManager.hapticFeedback)
                    Toggle("Sound Effects", isOn: $settingsManager.soundEffects)
                }
                
                // ===== NETWORK SECTION =====
                Section(header: Text("Network")) {
                    HStack {
                        Text("Port")
                        Spacer()
                        TextField("9876", value: $settingsManager.port, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Toggle("Auto-Connect", isOn: $settingsManager.autoConnect)
                    Toggle("Auto-Reconnect", isOn: $settingsManager.autoReconnect)
                }
                
                // ===== SCREEN MIRRORING SECTION =====
                Section(header: Text("Screen Mirroring")) {
                    Picker("Quality", selection: $settingsManager.streamQuality) {
                        Text("Very Low (144p) - Ultra Fast").tag(StreamQuality.veryLow)
                        Text("Low (720p)").tag(StreamQuality.low)
                        Text("Medium (1080p)").tag(StreamQuality.medium)
                        Text("High (1440p)").tag(StreamQuality.high)
                    }
                    
                    Toggle("Low Latency Mode", isOn: $settingsManager.lowLatencyMode)
                    Toggle("Very Low Latency Mode (144p)", isOn: $settingsManager.veryLowLatencyMode)
                        .onChange(of: settingsManager.veryLowLatencyMode) { newValue in
                            if newValue {
                                settingsManager.streamQuality = .veryLow
                                settingsManager.lowLatencyMode = true
                            }
                        }
                }
                
                // ===== PERFORMANCE SECTION =====
                Section(header: Text("Performance")) {
                    Toggle("Performance Mode", isOn: $settingsManager.performanceMode)
                    Toggle("Battery Saver", isOn: $settingsManager.batterySaver)
                    
                    VStack(alignment: .leading) {
                        Text("Touch Rate: \(Int(settingsManager.touchRate)) Hz")
                        Slider(value: $settingsManager.touchRate, in: 60...240, step: 60)
                    }
                }
                
                // ===== STATISTICS SECTION =====
                Section(header: Text("Statistics")) {
                    // TODO: Add stats when managers are added to Xcode project
                    Text("Statistics coming soon")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                // ===== CALIBRATION SECTION =====
                Section(header: Text("Calibration")) {
                    Button("Calibrate Tablet Area") {
                        // TODO: Show calibration wizard
                    }
                    
                    Button("Reset to Defaults") {
                        settingsManager.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
                
                // ===== ABOUT SECTION =====
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2025.10.30")
                            .foregroundColor(.gray)
                    }
                    
                    Link("GitHub Repository", destination: URL(string: "https://github.com/yasicreeper/Penrion")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
