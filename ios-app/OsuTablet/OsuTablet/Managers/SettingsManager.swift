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
    
    // New features
    @Published var blackScreenMode: Bool = false
    @Published var blackScreenButtonEnabled: Bool = true
    @Published var alwaysOnDisplay: Bool = false
    @Published var keepScreenOn: Bool = true
    @Published var inactivityTimeout: Double = 300.0 // 5 minutes
    @Published var fullscreenMode: Bool = false
    @Published var veryLowLatencyMode: Bool = false
    
    // OSU! Mode Presets
    @Published var osuWindowSize: OsuWindowSize = .standard
    @Published var osuProMode: Bool = false
    
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
        
        // New features
        blackScreenMode = defaults.bool(forKey: "blackScreenMode")
        blackScreenButtonEnabled = defaults.bool(forKey: "blackScreenButtonEnabled", defaultValue: true)
        alwaysOnDisplay = defaults.bool(forKey: "alwaysOnDisplay")
        keepScreenOn = defaults.bool(forKey: "keepScreenOn", defaultValue: true)
        inactivityTimeout = defaults.double(forKey: "inactivityTimeout", defaultValue: 300.0)
        fullscreenMode = defaults.bool(forKey: "fullscreenMode")
        veryLowLatencyMode = defaults.bool(forKey: "veryLowLatencyMode")
        
        if let sizeRaw = defaults.string(forKey: "osuWindowSize"),
           let size = OsuWindowSize(rawValue: sizeRaw) {
            osuWindowSize = size
        }
        osuProMode = defaults.bool(forKey: "osuProMode")
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
        
        // New feature bindings
        $blackScreenMode
            .sink { self.defaults.set($0, forKey: "blackScreenMode") }
            .store(in: &cancellables)
        
        $blackScreenButtonEnabled
            .sink { self.defaults.set($0, forKey: "blackScreenButtonEnabled") }
            .store(in: &cancellables)
        
        $alwaysOnDisplay
            .sink { self.defaults.set($0, forKey: "alwaysOnDisplay") }
            .store(in: &cancellables)
        
        $keepScreenOn
            .sink { self.defaults.set($0, forKey: "keepScreenOn") }
            .store(in: &cancellables)
        
        $fullscreenMode
            .sink { self.defaults.set($0, forKey: "fullscreenMode") }
            .store(in: &cancellables)
        
        $veryLowLatencyMode
            .sink { self.defaults.set($0, forKey: "veryLowLatencyMode") }
            .store(in: &cancellables)
        
        $osuProMode
            .sink { self.defaults.set($0, forKey: "osuProMode") }
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

enum StreamQuality: String, CaseIterable {
    case veryLow = "Very Low (144p)"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case ultra = "Ultra"
}

enum PressureCurve: String, CaseIterable {
    case linear = "Linear"
    case exponential = "Exponential"
    case logarithmic = "Logarithmic"
    case custom = "Custom"
}

enum OsuWindowSize: String, CaseIterable {
    case tiny = "Tiny (640x480)"
    case small = "Small (800x600)"
    case standard = "Standard (1024x768)"
    case large = "Large (1280x960)"
    case pro = "Pro (1920x1080)"
    
    var displayName: String {
        return rawValue
    }
    
    var resolution: (width: Int, height: Int) {
        switch self {
        case .tiny: return (640, 480)
        case .small: return (800, 600)
        case .standard: return (1024, 768)
        case .large: return (1280, 960)
        case .pro: return (1920, 1080)
        }
    }
}
