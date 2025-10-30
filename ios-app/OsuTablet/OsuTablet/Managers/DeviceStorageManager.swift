import Foundation

class DeviceStorageManager: ObservableObject {
    @Published var savedDevices: [SavedDevice] = []
    @Published var defaultDevice: SavedDevice?
    
    private let savedDevicesKey = "savedDevices"
    private let defaultDeviceKey = "defaultDevice"
    
    init() {
        loadSavedDevices()
        loadDefaultDevice()
    }
    
    func saveDevice(_ device: DiscoveredDevice, asDefault: Bool = false) {
        let savedDevice = SavedDevice(
            id: UUID().uuidString,
            name: device.name,
            ipAddress: device.ipAddress,
            lastConnected: Date()
        )
        
        // Add to saved devices if not already there
        if !savedDevices.contains(where: { $0.ipAddress == device.ipAddress }) {
            savedDevices.append(savedDevice)
            persistSavedDevices()
        }
        
        // Set as default if requested
        if asDefault {
            defaultDevice = savedDevice
            persistDefaultDevice()
        }
        
        print("✅ Device saved: \(device.name) (\(device.ipAddress))")
    }
    
    func removeDevice(_ device: SavedDevice) {
        savedDevices.removeAll { $0.id == device.id }
        persistSavedDevices()
        
        // Clear default if it was the default device
        if defaultDevice?.id == device.id {
            defaultDevice = nil
            persistDefaultDevice()
        }
    }
    
    func setDefaultDevice(_ device: SavedDevice) {
        defaultDevice = device
        persistDefaultDevice()
    }
    
    func updateLastConnected(_ ipAddress: String) {
        if let index = savedDevices.firstIndex(where: { $0.ipAddress == ipAddress }) {
            savedDevices[index].lastConnected = Date()
            persistSavedDevices()
        }
    }
    
    private func loadSavedDevices() {
        if let data = UserDefaults.standard.data(forKey: savedDevicesKey),
           let devices = try? JSONDecoder().decode([SavedDevice].self, from: data) {
            savedDevices = devices
        }
    }
    
    private func persistSavedDevices() {
        if let data = try? JSONEncoder().encode(savedDevices) {
            UserDefaults.standard.set(data, forKey: savedDevicesKey)
        }
    }
    
    private func loadDefaultDevice() {
        if let data = UserDefaults.standard.data(forKey: defaultDeviceKey),
           let device = try? JSONDecoder().decode(SavedDevice.self, from: data) {
            defaultDevice = device
        }
    }
    
    private func persistDefaultDevice() {
        if let device = defaultDevice,
           let data = try? JSONEncoder().encode(device) {
            UserDefaults.standard.set(data, forKey: defaultDeviceKey)
        } else {
            UserDefaults.standard.removeObject(forKey: defaultDeviceKey)
        }
    }
}

struct SavedDevice: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let ipAddress: String
    var lastConnected: Date
}
