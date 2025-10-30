using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using OsuTabletDriver.Services;

namespace OsuTabletDriver
{
    public class ConnectionServer
    {
        private readonly int _port;
        private readonly VirtualTabletDriver _driver;
        private readonly ScreenCaptureService _screenCapture;
        private readonly ConnectionHistory _connectionHistory;
        private TcpListener? _listener;
        private TcpClient? _client;
        private NetworkStream? _stream;
        private CancellationTokenSource? _cts;
        private bool _isRunning = false;
        private string? _currentClientIp;

        // Performance metrics
        private readonly Queue<DateTime> _touchTimestamps = new Queue<DateTime>();
        private readonly Queue<double> _latencies = new Queue<double>();
        private const int MaxQueueSize = 100;
        private System.Timers.Timer? _metricsTimer;

        public event EventHandler<string>? ClientConnected;
        public event EventHandler? ClientDisconnected;
        public event EventHandler<TouchData>? TouchDataReceived;
        public event EventHandler<dynamic>? SettingsReceived; // NEW: For Windows UI to receive iPad settings

        public double AverageLatency => _latencies.Count > 0 ? _latencies.Average() : 0;
        public int TouchRate { get; private set; }

        // NEW: Method to send settings TO iPad from Windows
        public void SendSettingsToiPad(object settings)
        {
            if (_stream == null || !_client?.Connected == true)
            {
                Console.WriteLine("❌ Cannot send settings: No iPad connected");
                return;
            }

            try
            {
                var json = JsonConvert.SerializeObject(settings);
                var jsonBytes = Encoding.UTF8.GetBytes(json);

                // Add length header
                var lengthBytes = BitConverter.GetBytes(jsonBytes.Length);
                if (BitConverter.IsLittleEndian)
                    Array.Reverse(lengthBytes);

                // Send length + data
                _stream.Write(lengthBytes, 0, 4);
                _stream.Write(jsonBytes, 0, jsonBytes.Length);
                _stream.Flush();

                Console.WriteLine($"📤 Sent settings to iPad: {json.Length} bytes");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to send settings to iPad: {ex.Message}");
            }
        }

        public ConnectionServer(int port, VirtualTabletDriver driver, ScreenCaptureService screenCapture)
        {
            _port = port;
            _driver = driver;
            _screenCapture = screenCapture;
            _connectionHistory = new ConnectionHistory();
            
            // Start metrics update timer (updates touch rate every 100ms)
            _metricsTimer = new System.Timers.Timer(100);
            _metricsTimer.Elapsed += (s, e) => UpdateTouchRate();
            _metricsTimer.Start();
            
            // Print saved connections on startup
            var savedConnections = _connectionHistory.GetSavedConnections();
            if (savedConnections.Any())
            {
                Console.WriteLine($"\n📋 {savedConnections.Count} saved connection(s):");
                foreach (var conn in savedConnections)
                {
                    var status = conn.IsOnline ? "🟢 ONLINE" : "⚫ offline";
                    var lastSeen = (DateTime.Now - conn.LastConnected).TotalMinutes;
                    Console.WriteLine($"  {status} {conn.DeviceName} ({conn.IpAddress}) - Last: {lastSeen:F0}m ago");
                }
                Console.WriteLine();
            }
        }

        public void Start()
        {
            if (_isRunning)
                return;

            _isRunning = true;
            _cts = new CancellationTokenSource();

            Task.Run(() => RunServer(_cts.Token));
        }

        public void Stop()
        {
            _isRunning = false;
            _cts?.Cancel();
            _stream?.Close();
            _client?.Close();
            _listener?.Stop();
            _metricsTimer?.Stop();
            _metricsTimer?.Dispose();
        }

        private async Task RunServer(CancellationToken token)
        {
            try
            {
                _listener = new TcpListener(IPAddress.Any, _port);
                _listener.Start();
                Console.WriteLine($"Server started on port {_port}");

                while (!token.IsCancellationRequested)
                {
                    try
                    {
                        _client = await _listener.AcceptTcpClientAsync();
                        _stream = _client.GetStream();

                        var clientEndpoint = _client.Client.RemoteEndPoint?.ToString() ?? "Unknown";
                        _currentClientIp = clientEndpoint.Split(':')[0]; // Extract IP without port
                        
                        Console.WriteLine($"✅ Client connected: {clientEndpoint}");
                        ClientConnected?.Invoke(this, clientEndpoint);
                        
                        // Save connection to history
                        _connectionHistory.SaveConnection(_currentClientIp, "iPad");

                        // Handle client communication
                        await HandleClient(token);
                    }
                    catch (Exception ex) when (!token.IsCancellationRequested)
                    {
                        Console.WriteLine($"❌ Client error: {ex.Message}");
                        if (_currentClientIp != null)
                        {
                            _connectionHistory.UpdateOnlineStatus(_currentClientIp, false);
                        }
                        ClientDisconnected?.Invoke(this, EventArgs.Empty);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Server error: {ex.Message}");
            }
        }

        private async Task HandleClient(CancellationToken token)
        {
            if (_stream == null)
                return;

            byte[] lengthBuffer = new byte[4];

            try
            {
                while (!token.IsCancellationRequested && _client?.Connected == true)
                {
                    // Read message length (4 bytes)
                    int bytesRead = await _stream.ReadAsync(lengthBuffer, 0, 4, token);
                    if (bytesRead != 4)
                        break;

                    // Convert to message length
                    if (BitConverter.IsLittleEndian)
                        Array.Reverse(lengthBuffer);
                    int messageLength = BitConverter.ToInt32(lengthBuffer, 0);

                    if (messageLength <= 0 || messageLength > 1024 * 1024) // Max 1MB
                        break;

                    // Read message data
                    byte[] messageBuffer = new byte[messageLength];
                    int totalRead = 0;
                    while (totalRead < messageLength)
                    {
                        int read = await _stream.ReadAsync(
                            messageBuffer,
                            totalRead,
                            messageLength - totalRead,
                            token
                        );
                        if (read == 0)
                            break;
                        totalRead += read;
                    }

                    if (totalRead == messageLength)
                    {
                        string json = Encoding.UTF8.GetString(messageBuffer);
                        ProcessMessage(json);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Handle client error: {ex.Message}");
            }
            finally
            {
                ClientDisconnected?.Invoke(this, EventArgs.Empty);
            }
        }

        private void ProcessMessage(string json)
        {
            try
            {
                var message = JsonConvert.DeserializeObject<Dictionary<string, object>>(json);
                if (message == null || !message.ContainsKey("type"))
                    return;

                string type = message["type"].ToString()!;

                switch (type)
                {
                    case "touch":
                        HandleTouchMessage(message);
                        break;
                    case "mouse":
                        HandleMouseMessage(message);
                        break;
                    case "stream_request":
                        HandleStreamRequest(message);
                        break;
                    case "settings":
                        HandleSettingsMessage(message);
                        break;
                    case "heartbeat":
                        HandleHeartbeat(message);
                        break;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Process message error: {ex.Message}");
            }
        }

        private void HandleTouchMessage(Dictionary<string, object> message)
        {
            try
            {
                double x = Convert.ToDouble(message["x"]);
                double y = Convert.ToDouble(message["y"]);
                double pressure = Convert.ToDouble(message["pressure"]);
                double timestamp = Convert.ToDouble(message["timestamp"]);

                // Calculate latency (iOS sends Unix timestamp in seconds)
                var receiveTime = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000.0;
                double latency = (receiveTime - timestamp) * 1000; // Convert to ms

                // Store latency for averaging
                lock (_latencies)
                {
                    _latencies.Enqueue(latency);
                    if (_latencies.Count > MaxQueueSize)
                        _latencies.Dequeue();
                }

                // Record touch timestamp for rate calculation
                lock (_touchTimestamps)
                {
                    _touchTimestamps.Enqueue(DateTime.Now);
                }

                // Send to driver
                var touchData = new TouchData
                {
                    X = x,
                    Y = y,
                    Pressure = pressure
                };

                TouchDataReceived?.Invoke(this, touchData);
                _driver.SendTouch(x, y, pressure);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Handle touch error: {ex.Message}");
            }
        }

        private void HandleMouseMessage(Dictionary<string, object> message)
        {
            try
            {
                double x = Convert.ToDouble(message["x"]);
                double y = Convert.ToDouble(message["y"]);
                bool pressed = Convert.ToBoolean(message["pressed"]);

                _driver.SendTouch(x, y, pressed ? 1.0 : 0.0);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Handle mouse error: {ex.Message}");
            }
        }

        private void HandleStreamRequest(Dictionary<string, object> message)
        {
            // Start screen streaming
            _screenCapture.StartCapture(_stream!);
        }

        private void HandleSettingsMessage(Dictionary<string, object> message)
        {
            try
            {
                Console.WriteLine("⚙️ Received settings from iPad:");
                
                // Extract settings with better type handling
                string quality = message.ContainsKey("streamQuality") ? message["streamQuality"].ToString()! : "Very Low (144p)";
                bool lowLatency = message.ContainsKey("lowLatencyMode") && Convert.ToBoolean(message["lowLatencyMode"]);
                bool veryLowLatency = message.ContainsKey("veryLowLatencyMode") && Convert.ToBoolean(message["veryLowLatencyMode"]);
                int targetFPS = message.ContainsKey("targetFPS") ? Convert.ToInt32(message["targetFPS"]) : 60;
                int jpegQuality = message.ContainsKey("jpegQuality") ? Convert.ToInt32(message["jpegQuality"]) : 30;
                double activeAreaWidth = message.ContainsKey("activeAreaWidth") ? Convert.ToDouble(message["activeAreaWidth"]) : 1.0;
                double activeAreaHeight = message.ContainsKey("activeAreaHeight") ? Convert.ToDouble(message["activeAreaHeight"]) : 1.0;
                bool perfMode = message.ContainsKey("performanceMode") && Convert.ToBoolean(message["performanceMode"]);
                
                // Fix: Handle touchRate as either int or double
                int touchRate = 500; // Default to max performance
                if (message.ContainsKey("touchRate"))
                {
                    var touchRateValue = message["touchRate"];
                    if (touchRateValue is int intValue)
                        touchRate = intValue;
                    else if (touchRateValue is long longValue)
                        touchRate = (int)longValue;
                    else
                        touchRate = (int)Convert.ToDouble(touchRateValue);
                }

                Console.WriteLine($"  - Stream Quality: {quality}");
                Console.WriteLine($"  - Low Latency Mode: {lowLatency}");
                Console.WriteLine($"  - Very Low Latency Mode: {veryLowLatency}");
                Console.WriteLine($"  - Target FPS: {targetFPS}");
                Console.WriteLine($"  - JPEG Quality: {jpegQuality}");
                Console.WriteLine($"  - Performance Mode: {perfMode}");
                Console.WriteLine($"  - Touch Rate: {touchRate} Hz");
                Console.WriteLine($"  - Active Area: {activeAreaWidth:F2} x {activeAreaHeight:F2}");

                // Apply Screen Capture settings
                int finalFPS = veryLowLatency ? Math.Max(120, targetFPS) : targetFPS;
                _screenCapture.SetTargetFPS(finalFPS);
                _screenCapture.SetQuality(jpegQuality);
                var (w, h) = MapQualityToSize(quality);
                _screenCapture.SetMaxDimensions(w, h);

                // Apply tablet area and touch rate - CRITICAL FIX
                _driver.SetTabletArea(0, 0, activeAreaWidth, activeAreaHeight);
                _driver.SetTargetTouchRate(touchRate);
                
                Console.WriteLine($"✅ Settings applied: {touchRate}Hz @ {finalFPS}FPS with {quality}");

                // NEW: Fire event so Windows UI can display iPad settings
                SettingsReceived?.Invoke(this, message);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Handle settings error: {ex.Message}");
                Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
            }
        }

        private (int width, int height) MapQualityToSize(string quality)
        {
            if (string.IsNullOrWhiteSpace(quality)) return (960, 540);
            var q = quality.ToLowerInvariant();
            if (q.Contains("very low")) return (854, 480);   // 480p
            if (q.Contains("low")) return (1280, 720);       // 720p
            if (q.Contains("medium")) return (1600, 900);    // 900p
            if (q.Contains("high")) return (1920, 1080);     // 1080p
            if (q.Contains("ultra")) return (2560, 1440);    // 1440p
            return (960, 540);
        }

        private void HandleHeartbeat(Dictionary<string, object> message)
        {
            // Update online status for current client
            if (_currentClientIp != null)
            {
                _connectionHistory.UpdateOnlineStatus(_currentClientIp, true);
            }
        }

        private void UpdateTouchRate()
        {
            // Calculate touches per second by removing old timestamps
            lock (_touchTimestamps)
            {
                var now = DateTime.Now;
                var cutoff = now.AddSeconds(-1.0); // Keep last 1 second of touches
                
                while (_touchTimestamps.Count > 0 && _touchTimestamps.Peek() < cutoff)
                    _touchTimestamps.Dequeue();
                
                TouchRate = _touchTimestamps.Count;
            }
        }
    }

    public class TouchData
    {
        public double X { get; set; }
        public double Y { get; set; }
        public double Pressure { get; set; }
    }
}
