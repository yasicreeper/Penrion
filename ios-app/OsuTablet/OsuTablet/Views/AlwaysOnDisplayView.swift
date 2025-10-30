import SwiftUI

struct AlwaysOnDisplayView: View {
    @EnvironmentObject var statsTracker: StatsTracker
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Pure black background for OLED power savings
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // Clock
                Text(timeString)
                    .font(.system(size: 72, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                // Date
                Text(dateString)
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                // Drawing stats
                VStack(spacing: 12) {
                    HStack(spacing: 30) {
                        StatBubble(
                            icon: "pencil.tip",
                            value: formatDuration(statsTracker.getActiveDrawingTime()),
                            label: "Active Time"
                        )
                        
                        StatBubble(
                            icon: "hand.tap",
                            value: "\(statsTracker.totalTouches)",
                            label: "Total Touches"
                        )
                    }
                    
                    StatBubble(
                        icon: "timer",
                        value: formatDuration(statsTracker.currentSessionTime),
                        label: "Session Time"
                    )
                }
                .padding(.bottom, 60)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: currentTime)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: currentTime)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
}

struct StatBubble: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
            
            Text(label)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}
