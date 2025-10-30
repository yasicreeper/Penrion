import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var deviceStorage: DeviceStorageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var isScanning = false
    @State private var showManualEntry = false
    @State private var showSavedDevices = false
    @State private var manualIPAddress = ""
    @State private var manualPort = "9876"
    @State private var autoConnectAttempted = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Image(systemName: "ipad.and.iphone")
                .font(.system(size: 80))
                .foregroundColor(themeManager.currentTheme.accentColor)
            
            Text("Penrion OSU! Tablet")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Transform your iPad into a professional OSU! tablet")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Saved Devices Section
            if !deviceStorage.savedDevices.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Saved Devices")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { showSavedDevices.toggle() }) {
                            Image(systemName: showSavedDevices ? "chevron.up" : "chevron.down")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    if showSavedDevices {
                        ForEach(deviceStorage.savedDevices) { device in
                            SavedDeviceRow(
                                device: device,
                                isDefault: deviceStorage.defaultDeviceId == device.id,
                                onConnect: {
                                    connectToSavedDevice(device)
                                },
                                onSetDefault: {
                                    deviceStorage.setDefaultDevice(device)
                                },
                                onDelete: {
                                    deviceStorage.removeDevice(device)
                                }
                            )
                        }
                    }
                }
                .padding(.top, 20)
            }
            
            // Scanning Section
            if isScanning {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.accentColor))
                        .scaleEffect(1.5)
                    
                    Text("Searching for Windows PC...")
                        .foregroundColor(.gray)
                    
                    if connectionManager.discoveredDevices.isEmpty {
                        Text("Make sure the Windows app is running")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.top, 20)
                
                // List discovered devices
                ForEach(connectionManager.discoveredDevices) { device in
                    DiscoveredDeviceRow(
                        device: device,
                        themeManager: themeManager,
                        onConnect: {
                            connectionManager.connect(to: device)
                        },
                        onSave: {
                            saveDevice(device)
                        }
                    )
                }
            } else {
                Button(action: {
                    isScanning = true
                    connectionManager.startDiscovery()
                }) {
                    HStack {
                        Image(systemName: "wifi")
                        Text("Find New PC")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: themeManager.currentTheme.backgroundColor),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                .padding(.top, 20)
            }
            
            Spacer()
            
            // Manual connection option
            VStack(spacing: 10) {
                Text("Having trouble?")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Button("Manual Connection") {
                    showManualEntry = true
                }
                .foregroundColor(themeManager.currentTheme.accentColor)
                .font(.caption)
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showManualEntry) {
            ManualConnectionSheet(
                ipAddress: $manualIPAddress,
                port: $manualPort,
                isPresented: $showManualEntry,
                themeManager: themeManager,
                onConnect: {
                    connectManually()
                }
            )
        }
        .onAppear {
            // Auto-connect to default device on startup
            if !autoConnectAttempted, let defaultDevice = deviceStorage.savedDevices.first(where: { $0.id == deviceStorage.defaultDeviceId }) {
                autoConnectAttempted = true
                connectToSavedDevice(defaultDevice)
                print("🔄 Auto-connecting to default device: \(defaultDevice.name)")
            } else {
                connectionManager.startDiscovery()
                isScanning = true
            }
        }
    }
    
    private func connectManually() {
        guard !manualIPAddress.isEmpty else { return }
        
        let device = DiscoveredDevice(
            id: "manual-\(manualIPAddress)",
            name: "Manual Connection",
            ipAddress: manualIPAddress,
            endpoint: nil
        )
        
        connectionManager.connect(to: device)
        
        // Save the device
        saveDiscoveredDevice(device)
        
        showManualEntry = false
    }
    
    private func connectToSavedDevice(_ savedDevice: SavedDevice) {
        let device = DiscoveredDevice(
            id: savedDevice.id,
            name: savedDevice.name,
            ipAddress: savedDevice.ipAddress,
            endpoint: nil
        )
        connectionManager.connect(to: device)
        deviceStorage.updateLastConnected(savedDevice)
    }
    
    private func saveDevice(_ device: DiscoveredDevice) {
        saveDiscoveredDevice(device)
    }
    
    private func saveDiscoveredDevice(_ device: DiscoveredDevice) {
        let savedDevice = SavedDevice(
            id: device.id,
            name: device.name,
            ipAddress: device.ipAddress
        )
        deviceStorage.saveDevice(savedDevice)
        print("💾 Saved device: \(savedDevice.name)")
    }
}

// Saved Device Row
struct SavedDeviceRow: View {
    let device: SavedDevice
    let isDefault: Bool
    let onConnect: () -> Void
    let onSetDefault: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            // Device Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(device.name)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    if isDefault {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                Text(device.ipAddress)
                    .foregroundColor(.gray)
                    .font(.caption)
                if let lastConnected = device.lastConnected {
                    Text("Last: \(lastConnected, formatter: dateFormatter)")
                        .foregroundColor(.gray.opacity(0.7))
                        .font(.caption2)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 10) {
                // Set Default Button
                Button(action: onSetDefault) {
                    Image(systemName: isDefault ? "star.fill" : "star")
                        .foregroundColor(isDefault ? .yellow : .gray)
                        .font(.system(size: 16))
                }
                
                // Connect Button
                Button(action: onConnect) {
                    Text("Connect")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.currentTheme.accentColor)
                        .cornerRadius(8)
                }
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal, 40)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

// Discovered Device Row (with save option)
struct DiscoveredDeviceRow: View {
    let device: DiscoveredDevice
    let themeManager: ThemeManager
    let onConnect: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "desktopcomputer")
                .font(.title2)
                .foregroundColor(themeManager.currentTheme.accentColor)
            
            VStack(alignment: .leading) {
                Text(device.name)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                Text(device.ipAddress)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                Button(action: onSave) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
                
                Button(action: onConnect) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal, 40)
    }
}

struct DeviceRow: View {
    let device: DiscoveredDevice
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "desktopcomputer")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(device.name)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    Text(device.ipAddress)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
        .padding(.horizontal, 40)
    }
}

// Manual Connection Sheet
struct ManualConnectionSheet: View {
    @Binding var ipAddress: String
    @Binding var port: String
    @Binding var isPresented: Bool
    let themeManager: ThemeManager
    let onConnect: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PC Connection Details")) {
                    TextField("IP Address (e.g., 192.168.1.100)", text: $ipAddress)
                        .keyboardType(.decimalPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("How to Find Your PC's IP")) {
                    Text("1. On Windows, open Command Prompt")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("2. Type: ipconfig")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("3. Look for 'IPv4 Address'")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section {
                    Button(action: {
                        onConnect()
                    }) {
                        HStack {
                            Spacer()
                            Text("Connect")
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Spacer()
                        }
                    }
                    .disabled(ipAddress.isEmpty)
                }
            }
            .navigationTitle("Manual Connection")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
}