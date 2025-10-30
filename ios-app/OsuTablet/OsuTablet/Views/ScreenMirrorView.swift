import SwiftUI
import AVFoundation

struct ScreenMirrorView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var receivedImage: UIImage?
    @State private var fps: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if let image = receivedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Waiting for screen...")
                            .foregroundColor(.white)
                    }
                }
                
                // FPS overlay
                VStack {
                    HStack {
                        Spacer()
                        Text("\(fps) FPS")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                    .padding()
                    Spacer()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        // Send touch to PC for mouse control
                        let normalizedPoint = CGPoint(
                            x: value.location.x / geometry.size.width,
                            y: value.location.y / geometry.size.height
                        )
                        connectionManager.sendMouseEvent(
                            location: normalizedPoint,
                            isPressed: true
                        )
                    }
                    .onEnded { _ in
                        connectionManager.sendMouseEvent(
                            location: .zero,
                            isPressed: false
                        )
                    }
            )
        }
        .onAppear {
            connectionManager.requestScreenStream()
        }
        .onReceive(connectionManager.screenFramePublisher) { image in
            receivedImage = image
            updateFPS()
        }
    }
    
    private func updateFPS() {
        // Simple FPS counter
        fps = connectionManager.currentFPS
    }
}
