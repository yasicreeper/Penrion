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
    
    private var sessionStartTime: Date?
    private var lastActiveTime: Date?
    private var isCurrentlyDrawing = false
    private var latencyHistory: [Double] = []
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
        saveStats()
    }
    
    func endSession() {
        if let start = sessionStartTime {
            let duration = Date().timeIntervalSince(start)
            totalDrawingTime += duration
            saveStats()
        }
        sessionStartTime = nil
    }
    
    func recordTouch() {
        totalTouches += 1
        sessionTouches += 1
        lastActiveTime = Date()
        
        if !isCurrentlyDrawing {
            isCurrentlyDrawing = true
        }
    }
    
    func recordLatency(_ latency: Double) {
        latencyHistory.append(latency)
        if latencyHistory.count > 100 {
            latencyHistory.removeFirst()
        }
        
        averageLatency = latencyHistory.reduce(0, +) / Double(latencyHistory.count)
        peakLatency = max(peakLatency, latency)
    }
    
    func getActiveDrawingTime() -> TimeInterval {
        // Returns time spent actively drawing (not idle time)
        return totalDrawingTime
    }
    
    func getIdleTime() -> TimeInterval {
        guard let lastActive = lastActiveTime else { return 0 }
        return Date().timeIntervalSince(lastActive)
    }
    
    func resetSessionStats() {
        currentSessionTime = 0
        sessionTouches = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let start = self.sessionStartTime {
                self.currentSessionTime = Date().timeIntervalSince(start)
            }
            
            // Check if drawing is active
            if let lastActive = self.lastActiveTime {
                let idle = Date().timeIntervalSince(lastActive)
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
        }
    }
    
    private func saveStats() {
        let stats = SavedStats(
            totalDrawingTime: totalDrawingTime,
            totalTouches: totalTouches,
            totalSessions: totalSessions
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
}
