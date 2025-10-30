import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var activeAreaWidth: Double = 1.0
    @Published var activeAreaHeight: Double = 1.0
    @Published var showActiveArea: Bool = false
    
    @Published var pressureCurve: PressureCurve = .linear
    @Published var pressureSensitivity: Double = 1.0
    
    @Published var visualFeedback: Bool = true
    @Published var hapticFeedback: Bool = false
    @Published var soundEffects: Bool = false
    
    @Published var port: Int = 9876
    @Published var autoConnect: Bool = true
    @Published var autoReconnect: Bool = true
    
    @Published var streamQuality: StreamQuality = .medium
    @Published var lowLatencyMode: Bool = true
    
    @Published var performanceMode: Bool = false
    @Published var batterySaver: Bool = false
    @Published var touchRate: Double = 120.0
    
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        setupBindings()
    }
    
    private func loadSettings() {
        activeAreaWidth = defaults.double(forKey: "activeAreaWidth", defaultValue: 1.0)
        activeAreaHeight = defaults.double(forKey: "activeAreaHeight", defaultValue: 1.0)
        showActiveArea = defaults.bool(forKey: "showActiveArea")
        
        if let curveRaw = defaults.string(forKey: "pressureCurve"),
           let curve = PressureCurve(rawValue: curveRaw) {
            pressureCurve = curve
        }
        pressureSensitivity = defaults.double(forKey: "pressureSensitivity", defaultValue: 1.0)
        
        visualFeedback = defaults.bool(forKey: "visualFeedback", defaultValue: true)
        hapticFeedback = defaults.bool(forKey: "hapticFeedback")
        soundEffects = defaults.bool(forKey: "soundEffects")
        
        port = defaults.integer(forKey: "port", defaultValue: 9876)
        autoConnect = defaults.bool(forKey: "autoConnect", defaultValue: true)
        autoReconnect = defaults.bool(forKey: "autoReconnect", defaultValue: true)
        
        if let qualityRaw = defaults.string(forKey: "streamQuality"),
           let quality = StreamQuality(rawValue: qualityRaw) {
            streamQuality = quality
        }
        lowLatencyMode = defaults.bool(forKey: "lowLatencyMode", defaultValue: true)
        
        performanceMode = defaults.bool(forKey: "performanceMode")
        batterySaver = defaults.bool(forKey: "batterySaver")
        touchRate = defaults.double(forKey: "touchRate", defaultValue: 120.0)
    }
    
    private func setupBindings() {
        $activeAreaWidth
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { self.defaults.set($0, forKey: "activeAreaWidth") }
            .store(in: &cancellables)
        
        $activeAreaHeight
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { self.defaults.set($0, forKey: "activeAreaHeight") }
            .store(in: &cancellables)
        
        $pressureSensitivity
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { self.defaults.set($0, forKey: "pressureSensitivity") }
            .store(in: &cancellables)
        
        $touchRate
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { self.defaults.set($0, forKey: "touchRate") }
            .store(in: &cancellables)
    }
    
    func resetToDefaults() {
        activeAreaWidth = 1.0
        activeAreaHeight = 1.0
        showActiveArea = false
        pressureCurve = .linear
        pressureSensitivity = 1.0
        visualFeedback = true
        hapticFeedback = false
        soundEffects = false
        port = 9876
        autoConnect = true
        autoReconnect = true
        streamQuality = .medium
        lowLatencyMode = true
        performanceMode = false
        batterySaver = false
        touchRate = 120.0
    }
    
    func applyPressureCurve(to pressure: Double) -> Double {
        let adjusted = pressure * pressureSensitivity
        
        switch pressureCurve {
        case .linear:
            return min(max(adjusted, 0), 1)
        case .exponential:
            return min(max(pow(adjusted, 2), 0), 1)
        case .logarithmic:
            return min(max(log(adjusted * 9 + 1) / log(10), 0), 1)
        case .custom:
            // Custom curve could be user-defined
            return min(max(adjusted, 0), 1)
        }
    }
}

extension UserDefaults {
    func double(forKey key: String, defaultValue: Double) -> Double {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return double(forKey: key)
    }
    
    func integer(forKey key: String, defaultValue: Int) -> Int {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return integer(forKey: key)
    }
    
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}
