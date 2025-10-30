using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Threading;

namespace OsuTabletDriver
{
    public partial class MainWindow : Window, INotifyPropertyChanged
    {
        private readonly ConnectionServer _server;
        private readonly VirtualTabletDriver _driver;
        private readonly ScreenCaptureService _screenCapture;
        private readonly DispatcherTimer _statsTimer;

        private string _statusText = "Waiting for connection...";
        private string _latencyText = "0 ms";
        private string _touchRateText = "0 Hz";
        private string _fpsText = "0 FPS";
        private bool _isConnected = false;
        private bool _isOsuDetected = false;

        public event PropertyChangedEventHandler? PropertyChanged;

        public string StatusText
        {
            get => _statusText;
            set { _statusText = value; OnPropertyChanged(nameof(StatusText)); }
        }

        public string LatencyText
        {
            get => _latencyText;
            set { _latencyText = value; OnPropertyChanged(nameof(LatencyText)); }
        }

        public string TouchRateText
        {
            get => _touchRateText;
            set { _touchRateText = value; OnPropertyChanged(nameof(TouchRateText)); }
        }

        public string FpsText
        {
            get => _fpsText;
            set { _fpsText = value; OnPropertyChanged(nameof(FpsText)); }
        }

        public bool IsConnected
        {
            get => _isConnected;
            set { _isConnected = value; OnPropertyChanged(nameof(IsConnected)); }
        }

        public bool IsOsuDetected
        {
            get => _isOsuDetected;
            set { _isOsuDetected = value; OnPropertyChanged(nameof(IsOsuDetected)); }
        }

        public MainWindow(ConnectionServer server, VirtualTabletDriver driver, ScreenCaptureService screenCapture)
        {
            InitializeComponent();
            DataContext = this;

            _server = server;
            _driver = driver;
            _screenCapture = screenCapture;

            // Subscribe to server events
            _server.ClientConnected += OnClientConnected;
            _server.ClientDisconnected += OnClientDisconnected;
            _server.TouchDataReceived += OnTouchDataReceived;

            // Start stats timer
            _statsTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(100)
            };
            _statsTimer.Tick += UpdateStats;
            _statsTimer.Start();

            // Check for OSU!
            CheckForOsu();
        }

        private void OnClientConnected(object? sender, string clientInfo)
        {
            Dispatcher.Invoke(() =>
            {
                IsConnected = true;
                StatusText = $"Connected: {clientInfo}";
            });
        }

        private void OnClientDisconnected(object? sender, EventArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                IsConnected = false;
                StatusText = "Disconnected - Waiting for connection...";
            });
        }

        private void OnTouchDataReceived(object? sender, TouchData data)
        {
            // Forward to driver
            _driver.SendTouch(data.X, data.Y, data.Pressure);
        }

        private void UpdateStats(object? sender, EventArgs e)
        {
            LatencyText = $"{_server.AverageLatency:F1} ms";
            TouchRateText = $"{_server.TouchRate} Hz";
            FpsText = $"{_screenCapture.CurrentFps} FPS";
        }

        private void CheckForOsu()
        {
            var osuProcess = System.Diagnostics.Process.GetProcessesByName("osu!");
            IsOsuDetected = osuProcess.Length > 0;

            // Keep checking
            var timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(2) };
            timer.Tick += (s, e) =>
            {
                var processes = System.Diagnostics.Process.GetProcessesByName("osu!");
                IsOsuDetected = processes.Length > 0;
            };
            timer.Start();
        }

        private void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        protected override void OnClosing(CancelEventArgs e)
        {
            _statsTimer.Stop();
            base.OnClosing(e);
        }
    }
}
