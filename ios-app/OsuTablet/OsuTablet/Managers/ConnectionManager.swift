import Foundation
import Network
import Combine
import UIKit

class ConnectionManager: ObservableObject {
    @Published var isConnected = false
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var currentFPS = 0
    @Published var connectionError: String?
    @Published var isReconnecting = false
    
    var screenFramePublisher = PassthroughSubject<UIImage, Never>()
    
    private var connection: NWConnection?
    private var listener: NWListener?
    private var browser: NWBrowser?
    private let port: UInt16 = 9876
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var reconnectTimer: Timer?
    private var currentDevice: DiscoveredDevice?
    
    func startDiscovery() {
        print("🔍 Starting network discovery")
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true
        
        // Also scan local network for devices
        Task {
            await scanLocalNetwork()
        }
        
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
        currentDevice = device
        connectionError = nil
        reconnectAttempts = 0
        attemptConnection(to: device)
    }
    
    private func attemptConnection(to device: DiscoveredDevice) {
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
                    self?.isReconnecting = false
                    self?.reconnectAttempts = 0
                    self?.connectionError = nil
                    self?.startReceiving()
                    print("✅ Connected to \(device.name)")
                case .failed(let error):
                    print("❌ Connection failed: \(error.localizedDescription)")
                    print("❌ Connection failed: \(error)")
                    self?.isConnected = false
                    self?.connectionError = "Failed: \(error.localizedDescription)"
                    self?.handleConnectionFailure()
                case .cancelled:
                    print("🚫 Connection cancelled")
                    self?.isConnected = false
                    self?.isReconnecting = false
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: .main)
        print("🔌 Connecting to \(device.name)...")
    }
    
    private func handleConnectionFailure() {
        guard let device = currentDevice, reconnectAttempts < maxReconnectAttempts else {
            connectionError = "Failed after \(maxReconnectAttempts) attempts"
            return
        }
        
        reconnectAttempts += 1
        isReconnecting = true
        let delay = Double(reconnectAttempts) * 2.0
        
        print("🔄 Retry \(reconnectAttempts)/\(maxReconnectAttempts) in \(delay)s...")
        
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.attemptConnection(to: device)
        }
    }
    
    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        reconnectAttempts = 0
        currentDevice = nil
        connection?.cancel()
        browser?.cancel()
        isConnected = false
        isReconnecting = false
        connectionError = nil
        print("🔌 Disconnected")
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
    
    private func scanLocalNetwork() async {
        // Get local IP to determine subnet
        guard let localIP = getLocalIPAddress() else { return }
        
        let components = localIP.split(separator: ".")
        guard components.count == 4 else { return }
        
        let subnet = "\(components[0]).\(components[1]).\(components[2])"
        
        // Scan common IPs in subnet (limited scan to avoid performance issues)
        let commonLastOctets = [1, 2, 100, 101, 102, 103, 104, 105, 150, 200, 254]
        
        for i in commonLastOctets {
            let testIP = "\(subnet).\(i)"
            
            // Skip if it's our own IP
            if testIP == localIP {
                continue
            }
            
            // Try to connect briefly to test
            Task {
                if await testConnection(to: testIP) {
                    DispatchQueue.main.async {
                        let device = DiscoveredDevice(
                            id: testIP,
                            name: "Windows PC (\(testIP))",
                            ipAddress: testIP,
                            endpoint: nil
                        )
                        
                        // Add if not already discovered
                        if !self.discoveredDevices.contains(where: { $0.ipAddress == testIP }) {
                            self.discoveredDevices.append(device)
                        }
                    }
                }
            }
        }
    }
    
    private func testConnection(to ipAddress: String) async -> Bool {
        let testActor = ConnectionTestActor()
        
        return await withCheckedContinuation { continuation in
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = true
            
            let host = NWEndpoint.Host(ipAddress)
            let port = NWEndpoint.Port(integerLiteral: self.port)
            let testConnection = NWConnection(host: host, port: port, using: parameters)
            
            testConnection.stateUpdateHandler = { state in
                Task {
                    let shouldContinue = await testActor.tryRespond()
                    guard shouldContinue else { return }
                    
                    switch state {
                    case .ready:
                        testConnection.cancel()
                        continuation.resume(returning: true)
                    case .failed, .cancelled:
                        continuation.resume(returning: false)
                    default:
                        break
                    }
                }
            }
            
            testConnection.start(queue: .global())
            
            // Timeout after 0.5 seconds
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                let shouldTimeout = await testActor.tryRespond()
                if shouldTimeout {
                    testConnection.cancel()
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    private actor ConnectionTestActor {
        private var hasResponded = false
        
        func tryRespond() -> Bool {
            if hasResponded {
                return false
            }
            hasResponded = true
            return true
        }
    }
    
    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" || name == "en1" { // WiFi interfaces
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
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
