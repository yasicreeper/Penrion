import Foundation
import UIKit
import Combine

class TouchManager: ObservableObject {
    @Published var latency: Double = 0
    @Published var touchRate: Int = 0
    @Published var currentPressure: Double = 0
    @Published var packetsPerSecond: Int = 0
    
    private var connectionManager: ConnectionManager?
    private var lastTouchTime: Date?
    private var touchCount = 0
    private var timer: Timer?
    
    private var pressureBuffer: [Double] = []
    private let maxPressureBufferSize = 10
    
    init() {
        startMetricsTimer()
    }
    
    func setConnectionManager(_ manager: ConnectionManager) {
        self.connectionManager = manager
    }
    
    func handleTouch(id: String, location: CGPoint, pressure: Double, phase: TouchPhase) {
        let startTime = Date()
        
        // Update pressure with intelligent smoothing (reduced buffer for responsiveness)
        updatePressure(pressure)
        
        // Log significant events only (began/ended for cleaner logs)
        if phase == .began || phase == .ended {
            print("👆 Touch \(phase.rawValue): id=\(id), pressure=\(String(format: "%.3f", pressure))")
        }
        
        // Send to PC with high-resolution timestamp for latency measurement
        let timestamp = Date().timeIntervalSince1970
        connectionManager?.sendTouchData(
            id: id,
            x: Double(location.x),
            y: Double(location.y),
            pressure: currentPressure,
            phase: phase,
            timestamp: timestamp
        )
        
        // Update metrics
        touchCount += 1
        lastTouchTime = Date()
        
        // Calculate latency (simplified - real latency would need server timestamp)
        latency = Date().timeIntervalSince(startTime) * 1000 // ms
    }
    
    private func updatePressure(_ newPressure: Double) {
        // Reduced buffer size for ultra-low latency (5 instead of 10)
        pressureBuffer.append(newPressure)
        if pressureBuffer.count > 5 {
            pressureBuffer.removeFirst()
        }
        
        // Weighted moving average favoring recent values for better responsiveness
        if pressureBuffer.count > 0 {
            var weightedSum = 0.0
            var weightSum = 0.0
            for (index, value) in pressureBuffer.enumerated() {
                let weight = Double(index + 1) // More weight to recent samples
                weightedSum += value * weight
                weightSum += weight
            }
            currentPressure = weightedSum / weightSum
        } else {
            currentPressure = newPressure
        }
    }
    
    private func startMetricsTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.packetsPerSecond = self.touchCount
                self.touchRate = self.touchCount
                self.touchCount = 0
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

// Extended touch info for Apple Pencil support
struct ExtendedTouchInfo {
    let location: CGPoint
    let pressure: Double
    let altitude: Double
    let azimuth: Double
    let timestamp: TimeInterval
}

extension TouchManager {
    func handleApplePencilTouch(touch: UITouch, in view: UIView) {
        let location = touch.location(in: view)
        let normalizedLocation = CGPoint(
            x: location.x / view.bounds.width,
            y: location.y / view.bounds.height
        )
        
        // Apple Pencil provides actual pressure
        let pressure = Double(touch.force / touch.maximumPossibleForce)
        
        let phase: TouchPhase
        switch touch.phase {
        case .began:
            phase = .began
        case .moved:
            phase = .moved
        case .ended:
            phase = .ended
        case .cancelled:
            phase = .cancelled
        default:
            phase = .moved
        }
        
        handleTouch(
            id: "\(touch.hashValue)",
            location: normalizedLocation,
            pressure: pressure,
            phase: phase
        )
    }
}
