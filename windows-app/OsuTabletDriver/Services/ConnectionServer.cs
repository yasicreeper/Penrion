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

        public event EventHandler<string>? ClientConnected;
        public event EventHandler? ClientDisconnected;
        public event EventHandler<TouchData>? TouchDataReceived;

        public double AverageLatency => _latencies.Count > 0 ? _latencies.Average() : 0;
        public int TouchRate { get; private set; }

        public ConnectionServer(int port, VirtualTabletDriver driver, ScreenCaptureService screenCapture)
        {
            _port = port;
            _driver = driver;
            _screenCapture = screenCapture;
            _connectionHistory = new ConnectionHistory();
            
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

                // Calculate latency
                var receiveTime = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000.0;
                double latency = (receiveTime - timestamp) * 1000; // ms

                _latencies.Enqueue(latency);
                if (_latencies.Count > MaxQueueSize)
                    _latencies.Dequeue();

                // Update touch rate
                var now = DateTime.Now;
                _touchTimestamps.Enqueue(now);
                while (_touchTimestamps.Count > 0 && (now - _touchTimestamps.Peek()).TotalSeconds > 1.0)
                    _touchTimestamps.Dequeue();
                TouchRate = _touchTimestamps.Count;

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
                
                // Extract settings
                if (message.ContainsKey("streamQuality"))
                {
                    string quality = message["streamQuality"].ToString()!;
                    Console.WriteLine($"  - Stream Quality: {quality}");
                }
                
                if (message.ContainsKey("lowLatencyMode"))
                {
                    bool lowLatency = Convert.ToBoolean(message["lowLatencyMode"]);
                    Console.WriteLine($"  - Low Latency Mode: {lowLatency}");
                }
                
                if (message.ContainsKey("veryLowLatencyMode"))
                {
                    bool veryLowLatency = Convert.ToBoolean(message["veryLowLatencyMode"]);
                    Console.WriteLine($"  - Very Low Latency Mode: {veryLowLatency}");
                }
                
                if (message.ContainsKey("targetFPS"))
                {
                    int targetFPS = Convert.ToInt32(message["targetFPS"]);
                    Console.WriteLine($"  - Target FPS: {targetFPS}");
                    _screenCapture.SetTargetFPS(targetFPS);
                }
                
                if (message.ContainsKey("jpegQuality"))
                {
                    int jpegQuality = Convert.ToInt32(message["jpegQuality"]);
                    Console.WriteLine($"  - JPEG Quality: {jpegQuality}");
                    _screenCapture.SetQuality(jpegQuality);
                }
                
                if (message.ContainsKey("performanceMode"))
                {
                    bool perfMode = Convert.ToBoolean(message["performanceMode"]);
                    Console.WriteLine($"  - Performance Mode: {perfMode}");
                }
                
                Console.WriteLine("✅ Settings applied successfully");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Handle settings error: {ex.Message}");
            }
        }

        private void HandleHeartbeat(Dictionary<string, object> message)
        {
            // Update online status for current client
            if (_currentClientIp != null)
            {
                _connectionHistory.UpdateOnlineStatus(_currentClientIp, true);
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
