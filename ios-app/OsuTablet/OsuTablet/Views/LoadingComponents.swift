import SwiftUI

/// Professional loading indicators and animations
struct LoadingView: View {
    let message: String
    let style: LoadingStyle
    @State private var isAnimating = false
    
    enum LoadingStyle {
        case spinner
        case dots
        case pulse
        case progress(Double) // 0.0 to 1.0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch style {
            case .spinner:
                SpinnerView()
            case .dots:
                DotsView()
            case .pulse:
                PulseView()
            case .progress(let progress):
                ProgressBarView(progress: progress)
            }
            
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .shadow(color: .blue.opacity(0.3), radius: 20)
        )
    }
}

struct SpinnerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .cyan]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 50, height: 50)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

struct DotsView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

struct PulseView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 50, height: 50)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(
                        Animation
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.5),
                        value: scale
                    )
            }
        }
        .onAppear {
            scale = 2.5
            opacity = 0
        }
    }
}

struct ProgressBarView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(animatedProgress), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: animatedProgress)
                }
            }
            .frame(width: 200, height: 8)
            
            Text("\(Int(animatedProgress * 100))%")
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            animatedProgress = newValue
        }
    }
}

/// Success/Error Toast Notification
struct ToastView: View {
    let message: String
    let type: ToastType
    @Binding var isShowing: Bool
    
    enum ToastType {
        case success
        case error
        case info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.title2)
            
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.9))
                .shadow(radius: 10)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

/// View modifier for toast
extension View {
    func toast(message: String, type: ToastView.ToastType, isShowing: Binding<Bool>) -> some View {
        ZStack {
            self
            
            if isShowing.wrappedValue {
                VStack {
                    ToastView(message: message, type: type, isShowing: isShowing)
                        .padding(.top, 50)
                    Spacer()
                }
                .transition(.move(edge: .top))
                .animation(.spring(), value: isShowing.wrappedValue)
            }
        }
    }
}

/// Saving indicator overlay
struct SavingIndicator: View {
    let isSaving: Bool
    
    var body: some View {
        if isSaving {
            HStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.7)
                
                Text("Saving...")
                    .foregroundColor(.white)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.7))
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
}
