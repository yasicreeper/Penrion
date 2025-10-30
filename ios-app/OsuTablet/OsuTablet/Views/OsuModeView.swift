import SwiftUI

struct OsuModeView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var touchManager: TouchManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var touches: [String: CGPoint] = [:]
    @State private var showStats = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // Active area visualization
                if settingsManager.showActiveArea {
                    Rectangle()
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        .frame(
                            width: geometry.size.width * settingsManager.activeAreaWidth,
                            height: geometry.size.height * settingsManager.activeAreaHeight
                        )
                }
                
                // Touch visualization
                ForEach(Array(touches.keys), id: \.self) { key in
                    if let point = touches[key] {
                        Circle()
                            .fill(Color.blue.opacity(0.6))
                            .frame(width: 60, height: 60)
                            .position(point)
                            .shadow(color: .blue, radius: 20)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Stats overlay
                if showStats {
                    VStack {
                        Spacer()
                        StatsOverlay()
                            .padding()
                    }
                }
                
                // Corner indicators
                VStack {
                    HStack {
                        // Connection indicator
                        HStack(spacing: 5) {
                            Circle()
                                .fill(connectionManager.isConnected ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            Text(connectionManager.isConnected ? "Connected" : "Disconnected")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        // Stats toggle
                        Button(action: { showStats.toggle() }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    Spacer()
                }
                
                // Invisible overlay for touch handling
                TouchHandlingView(
                    geometry: geometry,
                    touches: $touches,
                    onTouch: { id, location, pressure, phase in
                        let normalizedPoint = normalizePoint(location, in: geometry.size)
                        touchManager.handleTouch(
                            id: id,
                            location: normalizedPoint,
                            pressure: pressure,
                            phase: phase
                        )
                    }
                )
            }
        }
        .onAppear {
            touchManager.setConnectionManager(connectionManager)
            print("✅ OsuModeView appeared - TouchManager connected")
        }
    }
    
    private func normalizePoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        // Normalize to 0-1 range
        let x = max(0, min(1, point.x / size.width))
        let y = max(0, min(1, point.y / size.height))
        return CGPoint(x: x, y: y)
    }
}

// UIKit wrapper for proper touch handling
struct TouchHandlingView: UIViewRepresentable {
    let geometry: GeometryProxy
    @Binding var touches: [String: CGPoint]
    let onTouch: (String, CGPoint, Double, TouchPhase) -> Void
    
    func makeUIView(context: Context) -> TouchCaptureView {
        let view = TouchCaptureView()
        view.touchHandler = onTouch
        view.touchesBinding = $touches
        view.backgroundColor = .clear
        print("✅ TouchCaptureView created")
        return view
    }
    
    func updateUIView(_ uiView: TouchCaptureView, context: Context) {
        uiView.touchHandler = onTouch
    }
}

class TouchCaptureView: UIView {
    var touchHandler: ((String, CGPoint, Double, TouchPhase) -> Void)?
    var touchesBinding: Binding<[String: CGPoint]>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        isUserInteractionEnabled = true
        print("✅ TouchCaptureView initialized - multitouch enabled")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("👆 Touches began: \(touches.count)")
        handleTouches(touches, phase: .began)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, phase: .moved)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("👆 Touches ended: \(touches.count)")
        handleTouches(touches, phase: .ended)
        // Remove from visualization
        for touch in touches {
            let id = "\(touch.hash)"
            DispatchQueue.main.async {
                self.touchesBinding?.wrappedValue.removeValue(forKey: id)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("👆 Touches cancelled: \(touches.count)")
        handleTouches(touches, phase: .cancelled)
        // Remove from visualization
        for touch in touches {
            let id = "\(touch.hash)"
            DispatchQueue.main.async {
                self.touchesBinding?.wrappedValue.removeValue(forKey: id)
            }
        }
    }
    
    private func handleTouches(_ touches: Set<UITouch>, phase: TouchPhase) {
        for touch in touches {
            let location = touch.location(in: self)
            let id = "\(touch.hash)"
            
            // Calculate pressure (Apple Pencil or finger)
            let pressure: Double
            if touch.type == .pencil || touch.type == .stylus {
                // Apple Pencil provides actual pressure
                pressure = touch.force > 0 ? Double(touch.force / touch.maximumPossibleForce) : 1.0
                print("✏️ Apple Pencil pressure: \(pressure)")
            } else {
                // Finger touch defaults to 1.0
                pressure = 1.0
            }
            
            // Update visualization
            DispatchQueue.main.async {
                self.touchesBinding?.wrappedValue[id] = location
            }
            
            // Send to handler
            print("📤 Sending touch: id=\(id), location=(\(location.x), \(location.y)), pressure=\(pressure), phase=\(phase)")
            touchHandler?(id, location, pressure, phase)
        }
    }
}

struct StatsOverlay: View {
    @EnvironmentObject var touchManager: TouchManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            StatRow(label: "Latency", value: "\(Int(touchManager.latency))ms")
            StatRow(label: "Touch Rate", value: "\(touchManager.touchRate) Hz")
            StatRow(label: "Pressure", value: String(format: "%.2f", touchManager.currentPressure))
            StatRow(label: "Packets/s", value: "\(touchManager.packetsPerSecond)")
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(15)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .font(.caption)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(width: 150)
    }
}
