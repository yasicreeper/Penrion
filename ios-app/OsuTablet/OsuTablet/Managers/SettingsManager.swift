import Foundation
import Combine

/// Professional Settings Manager with automatic persistence
class SettingsManager: ObservableObject {
    // MARK: - Published Settings (Auto-save on change)
    
    @Published var activeAreaWidth: Double = 1.0 { didSet { save("activeAreaWidth", activeAreaWidth) } }
    @Published var activeAreaHeight: Double = 1.0 { didSet { save("activeAreaHeight", activeAreaHeight) } }
    @Published var showActiveArea: Bool = false { didSet { save("showActiveArea", showActiveArea) } }
    
    @Published var pressureCurve: PressureCurve = .linear { didSet { save("pressureCurve", pressureCurve.rawValue) } }
    @Published var pressureSensitivity: Double = 1.0 { didSet { save("pressureSensitivity", pressureSensitivity) } }
    
    @Published var visualFeedback: Bool = true { didSet { save("visualFeedback", visualFeedback) } }
    @Published var hapticFeedback: Bool = false { didSet { save("hapticFeedback", hapticFeedback) } }
    @Published var soundEffects: Bool = false { didSet { save("soundEffects", soundEffects) } }
    
    @Published var port: Int = 9876 { didSet { save("port", port) } }
    @Published var autoConnect: Bool = true { didSet { save("autoConnect", autoConnect) } }
    @Published var autoReconnect: Bool = true { didSet { save("autoReconnect", autoReconnect) } }
    
    @Published var streamQuality: StreamQuality = .veryLow { didSet { save("streamQuality", streamQuality.rawValue) } }
    @Published var lowLatencyMode: Bool = true { didSet { save("lowLatencyMode", lowLatencyMode) } }
    
    @Published var performanceMode: Bool = true { didSet { save("performanceMode", performanceMode) } }
    @Published var batterySaver: Bool = false { didSet { save("batterySaver", batterySaver) } }
    @Published var touchRate: Double = 120.0 { didSet { save("touchRate", touchRate) } } // Realistic: 60-200Hz
    
    // Display features
    @Published var blackScreenMode: Bool = false { didSet { save("blackScreenMode", blackScreenMode) } }
    @Published var blackScreenButtonEnabled: Bool = true { didSet { save("blackScreenButtonEnabled", blackScreenButtonEnabled) } }
    @Published var alwaysOnDisplay: Bool = false { didSet { save("alwaysOnDisplay", alwaysOnDisplay) } }
    @Published var keepScreenOn: Bool = true { didSet { save("keepScreenOn", keepScreenOn) } }
    @Published var inactivityTimeout: Double = 300.0 { didSet { save("inactivityTimeout", inactivityTimeout) } }
    @Published var fullscreenMode: Bool = false { didSet { save("fullscreenMode", fullscreenMode) } }
    @Published var veryLowLatencyMode: Bool = true { didSet { save("veryLowLatencyMode", veryLowLatencyMode) } }
    
    // OSU! Mode Presets
    @Published var osuWindowSize: OsuWindowSize = .standard { didSet { save("osuWindowSize", osuWindowSize.rawValue) } }
    @Published var osuProMode: Bool = false { didSet { save("osuProMode", osuProMode) } }
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var lastSaveTime: Date?
    
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    private var isLoadingSettings = false // Prevents saving during load
    
    init() {
        print("⚙️ Initializing Settings Manager...")
        isLoadingSettings = true
        loadSettings()
        isLoadingSettings = false
        print("✅ Settings Manager ready")
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
        } else {
            streamQuality = .veryLow
        }
        lowLatencyMode = defaults.bool(forKey: "lowLatencyMode", defaultValue: true)
        
        performanceMode = defaults.bool(forKey: "performanceMode", defaultValue: true)
        batterySaver = defaults.bool(forKey: "batterySaver")
        touchRate = defaults.double(forKey: "touchRate", defaultValue: 120.0) // Realistic default: 120Hz
        
        // New features
        blackScreenMode = defaults.bool(forKey: "blackScreenMode")
        blackScreenButtonEnabled = defaults.bool(forKey: "blackScreenButtonEnabled", defaultValue: true)
        alwaysOnDisplay = defaults.bool(forKey: "alwaysOnDisplay")
        keepScreenOn = defaults.bool(forKey: "keepScreenOn", defaultValue: true)
        inactivityTimeout = defaults.double(forKey: "inactivityTimeout", defaultValue: 300.0)
        fullscreenMode = defaults.bool(forKey: "fullscreenMode")
        veryLowLatencyMode = defaults.bool(forKey: "veryLowLatencyMode", defaultValue: true)
        
        if let sizeRaw = defaults.string(forKey: "osuWindowSize"),
           let size = OsuWindowSize(rawValue: sizeRaw) {
            osuWindowSize = size
        }
        osuProMode = defaults.bool(forKey: "osuProMode")
        
        print("✅ All settings loaded")
    }
    
    private func save(_ key: String, _ value: Any) {
        guard !isLoadingSettings else { return }
        
        isSaving = true
        defaults.set(value, forKey: key)
        defaults.synchronize()
        lastSaveTime = Date()
        
        // Show saving indicator briefly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.isSaving = false
        }
        
        print("💾 Auto-saved: \(key) = \(value)")
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
        streamQuality = .veryLow
        lowLatencyMode = true
        performanceMode = true
        batterySaver = false
        touchRate = 500.0
        veryLowLatencyMode = true
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
