import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
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
                
                Section(header: Text("Touch Feedback")) {
                    Toggle("Visual Feedback", isOn: $settingsManager.visualFeedback)
                    Toggle("Haptic Feedback", isOn: $settingsManager.hapticFeedback)
                    Toggle("Sound Effects", isOn: $settingsManager.soundEffects)
                }
                
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
                
                Section(header: Text("Screen Mirroring")) {
                    Picker("Quality", selection: $settingsManager.streamQuality) {
                        Text("Low (720p)").tag(StreamQuality.low)
                        Text("Medium (1080p)").tag(StreamQuality.medium)
                        Text("High (1440p)").tag(StreamQuality.high)
                    }
                    
                    Toggle("Low Latency Mode", isOn: $settingsManager.lowLatencyMode)
                }
                
                Section(header: Text("Performance")) {
                    Toggle("Performance Mode", isOn: $settingsManager.performanceMode)
                    Toggle("Battery Saver", isOn: $settingsManager.batterySaver)
                    
                    VStack(alignment: .leading) {
                        Text("Touch Rate: \(settingsManager.touchRate) Hz")
                        Slider(value: $settingsManager.touchRate, in: 60...240, step: 60)
                    }
                }
                
                Section(header: Text("Calibration")) {
                    Button("Calibrate Tablet Area") {
                        // TODO: Show calibration wizard
                    }
                    
                    Button("Reset to Defaults") {
                        settingsManager.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
                
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
                    
                    Link("GitHub Repository", destination: URL(string: "https://github.com/yourusername/penrion")!)
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

enum PressureCurve: String, Codable {
    case linear, exponential, logarithmic, custom
}

enum StreamQuality: String, Codable {
    case low, medium, high
}
