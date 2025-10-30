using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace OsuTabletDriver.Services
{
    public class SavedConnection
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string DeviceName { get; set; } = "iPad";
        public string IpAddress { get; set; } = "";
        public DateTime LastConnected { get; set; } = DateTime.Now;
        public bool IsOnline { get; set; } = false;
        public int ConnectionCount { get; set; } = 1;
    }

    public class ConnectionHistory
    {
        private static readonly string HistoryFilePath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "Penrion",
            "connection_history.json"
        );

        private List<SavedConnection> _savedConnections = new List<SavedConnection>();
        private System.Timers.Timer? _statusCheckTimer;

        public event EventHandler<List<SavedConnection>>? ConnectionsUpdated;

        public ConnectionHistory()
        {
            LoadConnections();
            StartStatusMonitoring();
        }

        public List<SavedConnection> GetSavedConnections()
        {
            return _savedConnections.OrderByDescending(c => c.LastConnected).ToList();
        }

        public void SaveConnection(string ipAddress, string deviceName = "iPad")
        {
            var existing = _savedConnections.FirstOrDefault(c => c.IpAddress == ipAddress);
            
            if (existing != null)
            {
                // Update existing
                existing.LastConnected = DateTime.Now;
                existing.ConnectionCount++;
                existing.IsOnline = true;
                existing.DeviceName = deviceName;
            }
            else
            {
                // Add new
                _savedConnections.Add(new SavedConnection
                {
                    IpAddress = ipAddress,
                    DeviceName = deviceName,
                    LastConnected = DateTime.Now,
                    IsOnline = true,
                    ConnectionCount = 1
                });
            }

            SaveToFile();
            ConnectionsUpdated?.Invoke(this, GetSavedConnections());
            Console.WriteLine($"💾 Saved connection: {deviceName} ({ipAddress})");
        }

        public void UpdateOnlineStatus(string ipAddress, bool isOnline)
        {
            var connection = _savedConnections.FirstOrDefault(c => c.IpAddress == ipAddress);
            if (connection != null && connection.IsOnline != isOnline)
            {
                connection.IsOnline = isOnline;
                SaveToFile();
                ConnectionsUpdated?.Invoke(this, GetSavedConnections());
                Console.WriteLine($"🔄 {connection.DeviceName} is now {(isOnline ? "ONLINE" : "offline")}");
            }
        }

        public void RemoveConnection(string ipAddress)
        {
            var connection = _savedConnections.FirstOrDefault(c => c.IpAddress == ipAddress);
            if (connection != null)
            {
                _savedConnections.Remove(connection);
                SaveToFile();
                ConnectionsUpdated?.Invoke(this, GetSavedConnections());
                Console.WriteLine($"🗑️ Removed connection: {connection.DeviceName}");
            }
        }

        private void LoadConnections()
        {
            try
            {
                if (File.Exists(HistoryFilePath))
                {
                    var json = File.ReadAllText(HistoryFilePath);
                    _savedConnections = JsonSerializer.Deserialize<List<SavedConnection>>(json) ?? new List<SavedConnection>();
                    Console.WriteLine($"📂 Loaded {_savedConnections.Count} saved connection(s)");
                }
                else
                {
                    Console.WriteLine("📂 No connection history found, starting fresh");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error loading connection history: {ex.Message}");
                _savedConnections = new List<SavedConnection>();
            }
        }

        private void SaveToFile()
        {
            try
            {
                var directory = Path.GetDirectoryName(HistoryFilePath);
                if (directory != null && !Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                }

                var json = JsonSerializer.Serialize(_savedConnections, new JsonSerializerOptions 
                { 
                    WriteIndented = true 
                });
                File.WriteAllText(HistoryFilePath, json);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error saving connection history: {ex.Message}");
            }
        }

        private void StartStatusMonitoring()
        {
            _statusCheckTimer = new System.Timers.Timer(5000); // Check every 5 seconds
            _statusCheckTimer.Elapsed += async (sender, e) =>
            {
                foreach (var connection in _savedConnections)
                {
                    bool isOnline = await CheckDeviceOnline(connection.IpAddress);
                    UpdateOnlineStatus(connection.IpAddress, isOnline);
                }
            };
            _statusCheckTimer.Start();
            Console.WriteLine("🔄 Status monitoring started (checking every 5s)");
        }

        private async Task<bool> CheckDeviceOnline(string ipAddress)
        {
            try
            {
                using var ping = new System.Net.NetworkInformation.Ping();
                var reply = await ping.SendPingAsync(ipAddress, 1000);
                return reply.Status == System.Net.NetworkInformation.IPStatus.Success;
            }
            catch
            {
                return false;
            }
        }

        public void Dispose()
        {
            _statusCheckTimer?.Stop();
            _statusCheckTimer?.Dispose();
        }
    }
}
