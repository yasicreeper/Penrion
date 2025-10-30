import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var isScanning = false
    @State private var showManualEntry = false
    @State private var manualIPAddress = ""
    @State private var manualPort = "9876"
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "ipad.and.iphone")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Penrion OSU! Tablet")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Transform your iPad into a professional OSU! tablet")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if isScanning {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                    
                    Text("Searching for Windows PC...")
                        .foregroundColor(.gray)
                    
                    if connectionManager.discoveredDevices.isEmpty {
                        Text("Make sure the Windows app is running")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.top, 40)
                
                // List discovered devices
                ForEach(connectionManager.discoveredDevices) { device in
                    DeviceRow(device: device) {
                        connectionManager.connect(to: device)
                    }
                }
            } else {
                Button(action: {
                    isScanning = true
                    connectionManager.startDiscovery()
                }) {
                    HStack {
                        Image(systemName: "wifi")
                        Text("Find PC")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                .padding(.top, 40)
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
                .foregroundColor(.blue)
                .font(.caption)
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showManualEntry) {
            ManualConnectionSheet(
                ipAddress: $manualIPAddress,
                port: $manualPort,
                isPresented: $showManualEntry,
                onConnect: {
                    connectManually()
                }
            )
        }
        .onAppear {
            connectionManager.startDiscovery()
            isScanning = true
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
        showManualEntry = false
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
