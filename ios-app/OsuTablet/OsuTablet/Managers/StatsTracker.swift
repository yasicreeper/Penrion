import Foundation
import Combine

class StatsTracker: ObservableObject {
    @Published var totalDrawingTime: TimeInterval = 0
    @Published var currentSessionTime: TimeInterval = 0
    @Published var totalTouches: Int = 0
    @Published var sessionTouches: Int = 0
    @Published var averageLatency: Double = 0
    @Published var peakLatency: Double = 0
    @Published var totalSessions: Int = 0
    @Published var currentDrawingTime: TimeInterval = 0
    @Published var idleTime: TimeInterval = 0
    @Published var isSessionActive: Bool = false
    @Published var averageTouchRate: Double = 0
    @Published var longestSessionTime: TimeInterval = 0
    
    var sessionStartTime: Date?
    private var lastActiveTime: Date?
    private var isCurrentlyDrawing = false
    var latencyHistory: [Double] = []
    private var timer: Timer?
    
    private let statsKey = "appStats"
    
    init() {
        loadStats()
        startTimer()
    }
    
    func startSession() {
        sessionStartTime = Date()
        sessionTouches = 0
        totalSessions += 1
        isSessionActive = true
        saveStats()
        print("📊 Session started - Total sessions: \(totalSessions)")
    }
    
    func endSession() {
        if let start = sessionStartTime {
            let duration = Date().timeIntervalSince(start)
            totalDrawingTime += duration
            if duration > longestSessionTime {
                longestSessionTime = duration
            }
            saveStats()
            print("📊 Session ended - Duration: \(Int(duration))s")
        }
        sessionStartTime = nil
        isSessionActive = false
    }
    
    func recordTouch() {
        totalTouches += 1
        sessionTouches += 1
        lastActiveTime = Date()
        
        if !isCurrentlyDrawing {
            isCurrentlyDrawing = true
            print("✏️ Drawing started")
        }
        
        // Update average touch rate
        if let start = sessionStartTime {
            let sessionMinutes = Date().timeIntervalSince(start) / 60.0
            if sessionMinutes > 0 {
                averageTouchRate = Double(sessionTouches) / sessionMinutes
            }
        }
    }
    
    func recordLatency(_ latency: Double) {
        latencyHistory.append(latency)
        if latencyHistory.count > 100 {
            latencyHistory.removeFirst()
        }
        
        averageLatency = latencyHistory.reduce(0, +) / Double(latencyHistory.count)
        
        // Update peak (best) latency
        if peakLatency == 0 || latency < peakLatency {
            peakLatency = latency
        }
    }
    
    func getActiveDrawingTime() -> TimeInterval {
        // Returns time spent actively drawing (not idle time)
        return currentDrawingTime
    }
    
    func getIdleTime() -> TimeInterval {
        guard let lastActive = lastActiveTime else { return 0 }
        return Date().timeIntervalSince(lastActive)
    }
    
    func resetSessionStats() {
        currentSessionTime = 0
        sessionTouches = 0
    }
    
    func resetStats() {
        totalDrawingTime = 0
        totalTouches = 0
        totalSessions = 0
        sessionTouches = 0
        averageLatency = 0
        peakLatency = 0
        currentDrawingTime = 0
        idleTime = 0
        averageTouchRate = 0
        longestSessionTime = 0
        latencyHistory.removeAll()
        saveStats()
        print("🔄 Stats reset")
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let start = self.sessionStartTime {
                self.currentSessionTime = Date().timeIntervalSince(start)
            }
            
            // Update drawing time
            if self.isCurrentlyDrawing {
                self.currentDrawingTime += 1.0
            }
            
            // Check if drawing is active
            if let lastActive = self.lastActiveTime {
                let idle = Date().timeIntervalSince(lastActive)
                self.idleTime = idle
                if idle > 2.0 {
                    self.isCurrentlyDrawing = false
                }
            }
        }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let stats = try? JSONDecoder().decode(SavedStats.self, from: data) {
            totalDrawingTime = stats.totalDrawingTime
            totalTouches = stats.totalTouches
            totalSessions = stats.totalSessions
            longestSessionTime = stats.longestSessionTime
        }
    }
    
    private func saveStats() {
        let stats = SavedStats(
            totalDrawingTime: totalDrawingTime,
            totalTouches: totalTouches,
            totalSessions: totalSessions,
            longestSessionTime: longestSessionTime
        )
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: statsKey)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct SavedStats: Codable {
    let totalDrawingTime: TimeInterval
    let totalTouches: Int
    let totalSessions: Int
    let longestSessionTime: TimeInterval
}
