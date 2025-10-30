import Foundation
import Network
import Combine

class ConnectionManager: ObservableObject {
    @Published var isConnected = false
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var currentFPS = 0
    
    var screenFramePublisher = PassthroughSubject<UIImage, Never>()
    
    private var connection: NWConnection?
    private var listener: NWListener?
    private var browser: NWBrowser?
    private let port: UInt16 = 9876
    
    func startDiscovery() {
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true
        
        // Create browser for network service discovery
        browser = NWBrowser(for: .bonjour(type: "_osutablet._tcp", domain: nil), using: parameters)
        
        browser?.stateUpdateHandler = { state in
            print("Browser state: \(state)")
        }
        
        browser?.browseResultsChangedHandler = { results, changes in
            DispatchQueue.main.async {
                self.discoveredDevices = results.map { result in
                    DiscoveredDevice(
                        id: UUID().uuidString,
                        name: result.endpoint.debugDescription,
                        ipAddress: self.extractIP(from: result.endpoint),
                        endpoint: result.endpoint
                    )
                }
            }
        }
        
        browser?.start(queue: .main)
    }
    
    func connect(to device: DiscoveredDevice) {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        
        if let endpoint = device.endpoint {
            connection = NWConnection(to: endpoint, using: parameters)
        } else {
            // Manual connection via IP
            let host = NWEndpoint.Host(device.ipAddress)
            let port = NWEndpoint.Port(integerLiteral: self.port)
            connection = NWConnection(host: host, port: port, using: parameters)
        }
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.startReceiving()
                case .failed(let error):
                    print("Connection failed: \(error)")
                    self?.isConnected = false
                case .cancelled:
                    self?.isConnected = false
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: .main)
    }
    
    func disconnect() {
        connection?.cancel()
        browser?.cancel()
        isConnected = false
    }
    
    func sendTouchData(id: String, x: Double, y: Double, pressure: Double, phase: TouchPhase) {
        guard let connection = connection else { return }
        
        let touchData: [String: Any] = [
            "type": "touch",
            "id": id,
            "x": x,
            "y": y,
            "pressure": pressure,
            "phase": phase.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: touchData) {
            var message = jsonData
            // Add message length header (4 bytes)
            var length = UInt32(jsonData.count).bigEndian
            let lengthData = Data(bytes: &length, count: 4)
            message = lengthData + jsonData
            
            connection.send(content: message, completion: .contentProcessed({ error in
                if let error = error {
                    print("Send error: \(error)")
                }
            }))
        }
    }
    
    func sendMouseEvent(location: CGPoint, isPressed: Bool) {
        guard let connection = connection else { return }
        
        let mouseData: [String: Any] = [
            "type": "mouse",
            "x": location.x,
            "y": location.y,
            "pressed": isPressed,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: mouseData) {
            var message = jsonData
            var length = UInt32(jsonData.count).bigEndian
            let lengthData = Data(bytes: &length, count: 4)
            message = lengthData + jsonData
            
            connection.send(content: message, completion: .contentProcessed({ _ in }))
        }
    }
    
    func requestScreenStream() {
        guard let connection = connection else { return }
        
        let request: [String: Any] = [
            "type": "stream_request",
            "quality": "medium"
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: request) {
            var message = jsonData
            var length = UInt32(jsonData.count).bigEndian
            let lengthData = Data(bytes: &length, count: 4)
            message = lengthData + jsonData
            
            connection.send(content: message, completion: .contentProcessed({ _ in }))
        }
    }
    
    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] data, _, _, error in
            guard let data = data, error == nil else {
                print("Receive error: \(String(describing: error))")
                return
            }
            
            // Read message length
            let length = data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            
            // Receive the actual message
            self?.connection?.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length)) { messageData, _, _, _ in
                if let messageData = messageData {
                    self?.handleReceivedData(messageData)
                }
                // Continue receiving
                self?.startReceiving()
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let type = json["type"] as? String {
            
            switch type {
            case "screen_frame":
                if let imageBase64 = json["image"] as? String,
                   let imageData = Data(base64Encoded: imageBase64),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.screenFramePublisher.send(image)
                    }
                }
            case "stats":
                if let fps = json["fps"] as? Int {
                    DispatchQueue.main.async {
                        self.currentFPS = fps
                    }
                }
            default:
                break
            }
        }
    }
    
    private func extractIP(from endpoint: NWEndpoint) -> String {
        switch endpoint {
        case .hostPort(let host, _):
            return "\(host)"
        default:
            return "Unknown"
        }
    }
}

struct DiscoveredDevice: Identifiable {
    let id: String
    let name: String
    let ipAddress: String
    var endpoint: NWEndpoint?
}

enum TouchPhase: String {
    case began, moved, ended, cancelled
}
