import SwiftUI

struct OsuModeView: View {
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
                        // Latency indicator
                        HStack(spacing: 5) {
                            Circle()
                                .fill(touchManager.latency < 10 ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                            Text("\(Int(touchManager.latency))ms")
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
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let normalizedPoint = normalizePoint(
                            value.location,
                            in: geometry.size
                        )
                        touches[value.id] = value.location
                        touchManager.handleTouch(
                            id: value.id,
                            location: normalizedPoint,
                            pressure: value.pressure,
                            phase: .moved
                        )
                    }
                    .onEnded { value in
                        touches.removeValue(forKey: value.id)
                        touchManager.handleTouch(
                            id: value.id,
                            location: .zero,
                            pressure: 0,
                            phase: .ended
                        )
                    }
            )
        }
    }
    
    private func normalizePoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        // Normalize to active area
        let x = point.x / size.width
        let y = point.y / size.height
        return CGPoint(x: x, y: y)
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

extension DragGesture.Value {
    var id: String {
        return "\(self.startLocation.x)-\(self.startLocation.y)"
    }
    
    var pressure: Double {
        // iOS doesn't expose pressure in DragGesture, would need UITouch
        return 1.0
    }
}
