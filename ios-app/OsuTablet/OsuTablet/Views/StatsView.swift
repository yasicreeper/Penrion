import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var statsTracker: StatsTracker
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Performance Statistics")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Track your drawing sessions and performance")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                
                // Quick Stats Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    StatCard(
                        title: "Total Sessions",
                        value: "\(statsTracker.totalSessions)",
                        icon: "calendar",
                        color: themeManager.currentTheme.accentColor
                    )
                    
                    StatCard(
                        title: "Active Drawing",
                        value: formatDuration(statsTracker.getActiveDrawingTime()),
                        icon: "pencil.tip",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Total Touches",
                        value: "\(statsTracker.totalTouches)",
                        icon: "hand.draw",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Avg Latency",
                        value: "\(Int(statsTracker.averageLatency))ms",
                        icon: "speedometer",
                        color: latencyColor(statsTracker.averageLatency)
                    )
                }
                .padding(.horizontal)
                
                // Session Stats
                if statsTracker.isSessionActive {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Session")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        SessionStatsCard(statsTracker: statsTracker, themeManager: themeManager)
                            .padding(.horizontal)
                    }
                }
                
                // Latency History Chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latency History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LatencyChartView(history: statsTracker.latencyHistory, themeManager: themeManager)
                        .frame(height: 200)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                
                // Peak Performance Stats
                VStack(alignment: .leading, spacing: 10) {
                    Text("Peak Performance")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        PeakStatRow(
                            label: "Best Latency",
                            value: "\(Int(statsTracker.peakLatency))ms",
                            icon: "bolt.fill",
                            color: .yellow
                        )
                        
                        PeakStatRow(
                            label: "Most Touches (Session)",
                            value: "\(statsTracker.sessionTouches)",
                            icon: "hand.tap.fill",
                            color: .purple
                        )
                        
                        PeakStatRow(
                            label: "Longest Session",
                            value: formatDuration(statsTracker.longestSessionTime),
                            icon: "timer",
                            color: .orange
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                // Touch Rate Info
                VStack(alignment: .leading, spacing: 10) {
                    Text("Touch Activity")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Average Touch Rate")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(Int(statsTracker.averageTouchRate)) touches/min")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                        Spacer()
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 50))
                            .foregroundColor(themeManager.currentTheme.accentColor.opacity(0.3))
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                // Reset Button
                Button(action: {
                    statsTracker.resetStats()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset All Statistics")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(15)
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
    
    private func latencyColor(_ latency: Double) -> Color {
        if latency < 10 {
            return .green
        } else if latency < 20 {
            return .yellow
        } else {
            return .red
        }
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// Session Stats Card
struct SessionStatsCard: View {
    @ObservedObject var statsTracker: StatsTracker
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Session Duration")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatSessionTime(statsTracker.sessionStartTime))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Touches")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(statsTracker.sessionTouches)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Drawing Time")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatDuration(statsTracker.currentDrawingTime))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Idle Time")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatDuration(statsTracker.idleTime))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.accentColor.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func formatSessionTime(_ startTime: Date?) -> String {
        guard let start = startTime else { return "0s" }
        let duration = Date().timeIntervalSince(start)
        return formatDuration(duration)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%dm %ds", minutes, secs)
    }
}

// Latency Chart View
struct LatencyChartView: View {
    let history: [Double]
    let themeManager: ThemeManager
    
    var body: some View {
        if history.isEmpty {
            VStack {
                Spacer()
                Text("No latency data yet")
                    .foregroundColor(.gray)
                Spacer()
            }
        } else {
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let dataPoints = history.suffix(50) // Last 50 points
                    
                    guard !dataPoints.isEmpty else { return }
                    
                    let maxLatency = dataPoints.max() ?? 50
                    let xStep = width / CGFloat(dataPoints.count - 1)
                    
                    for (index, latency) in dataPoints.enumerated() {
                        let x = CGFloat(index) * xStep
                        let y = height - (CGFloat(latency) / CGFloat(maxLatency) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(themeManager.currentTheme.accentColor, lineWidth: 2)
                
                // Average line
                Path { path in
                    let avg = history.suffix(50).reduce(0, +) / Double(history.suffix(50).count)
                    let maxLatency = history.suffix(50).max() ?? 50
                    let y = geometry.size.height - (CGFloat(avg) / CGFloat(maxLatency) * geometry.size.height)
                    
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(Color.yellow.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
            }
        }
    }
}

// Peak Stat Row
struct PeakStatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}
