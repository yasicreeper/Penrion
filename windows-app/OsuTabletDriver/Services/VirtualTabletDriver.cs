using System;
using System.Runtime.InteropServices;

namespace OsuTabletDriver
{
    /// <summary>
    /// Virtual tablet driver that simulates a HID tablet device
    /// Uses Windows User32 API for absolute positioning
    /// </summary>
    public class VirtualTabletDriver : IDisposable
    {
        private bool _isInitialized = false;
        private readonly object _lock = new object();
        
        // Screen dimensions
        private int _screenWidth;
        private int _screenHeight;
        
        // Tablet area mapping
        private double _tabletAreaX = 0;
        private double _tabletAreaY = 0;
        private double _tabletAreaWidth = 1.0;
        private double _tabletAreaHeight = 1.0;

        // Performance tracking
        private DateTime _lastTouchTime = DateTime.MinValue;
        private DateTime _lastProcessedTouch = DateTime.MinValue;
        private int _touchCount = 0;
        private int _targetTouchRate = 240; // Hz
        private double _minTouchInterval = 1.0 / 240.0; // seconds

        // Windows API imports
        [DllImport("user32.dll")]
        private static extern bool SetCursorPos(int x, int y);

        [DllImport("user32.dll")]
        private static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);

        [DllImport("user32.dll")]
        private static extern int GetSystemMetrics(int nIndex);

        // Mouse event constants
        private const uint MOUSEEVENTF_ABSOLUTE = 0x8000;
        private const uint MOUSEEVENTF_MOVE = 0x0001;
        private const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
        private const uint MOUSEEVENTF_LEFTUP = 0x0004;
        private const uint MOUSEEVENTF_VIRTUALDESK = 0x4000;

        private const int SM_CXSCREEN = 0;
        private const int SM_CYSCREEN = 1;

        public bool IsInitialized => _isInitialized;
        public int TouchRate { get; private set; }

        public void SetTargetTouchRate(int rateHz)
        {
            lock (_lock)
            {
                _targetTouchRate = Math.Clamp(rateHz, 60, 500);
                _minTouchInterval = 1.0 / _targetTouchRate;
                Console.WriteLine($"🎯 Target touch rate set to: {_targetTouchRate} Hz (min interval: {_minTouchInterval * 1000:F2}ms)");
            }
        }

        public void Initialize()
        {
            lock (_lock)
            {
                if (_isInitialized)
                    return;

                // Get screen dimensions
                _screenWidth = GetSystemMetrics(SM_CXSCREEN);
                _screenHeight = GetSystemMetrics(SM_CYSCREEN);

                _isInitialized = true;
                Console.WriteLine($"Virtual Tablet Driver initialized - Screen: {_screenWidth}x{_screenHeight}");
            }
        }

        public void SetTabletArea(double x, double y, double width, double height)
        {
            lock (_lock)
            {
                _tabletAreaX = Math.Max(0, Math.Min(1, x));
                _tabletAreaY = Math.Max(0, Math.Min(1, y));
                _tabletAreaWidth = Math.Max(0, Math.Min(1, width));
                _tabletAreaHeight = Math.Max(0, Math.Min(1, height));
            }
        }

        public void SendTouch(double normalizedX, double normalizedY, double pressure)
        {
            if (!_isInitialized)
                return;

            lock (_lock)
            {
                try
                {
                    // Throttle based on target touch rate
                    var now = DateTime.Now;
                    var timeSinceLastTouch = (now - _lastProcessedTouch).TotalSeconds;
                    
                    if (timeSinceLastTouch < _minTouchInterval)
                    {
                        // Skip this touch to maintain target rate
                        return;
                    }
                    
                    _lastProcessedTouch = now;

                    // Map normalized coordinates to screen space
                    // Apply tablet area mapping
                    double mappedX = _tabletAreaX + (normalizedX * _tabletAreaWidth);
                    double mappedY = _tabletAreaY + (normalizedY * _tabletAreaHeight);

                    // Convert to absolute screen coordinates
                    int screenX = (int)(mappedX * _screenWidth);
                    int screenY = (int)(mappedY * _screenHeight);

                    // Clamp to screen bounds
                    screenX = Math.Max(0, Math.Min(_screenWidth - 1, screenX));
                    screenY = Math.Max(0, Math.Min(_screenHeight - 1, screenY));

                    // Convert to mouse_event coordinates (0-65535 range)
                    int mouseX = (int)((screenX * 65535.0) / _screenWidth);
                    int mouseY = (int)((screenY * 65535.0) / _screenHeight);

                    // Send absolute mouse move ONLY (no clicking)
                    // OSU! mode: Let the iPad's physical taps handle clicking through iOS
                    // This prevents lag from simulated clicks
                    mouse_event(
                        MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_VIRTUALDESK,
                        mouseX,
                        mouseY,
                        0,
                        UIntPtr.Zero
                    );

                    // NOTE: No automatic clicking! The iPad detects taps natively.
                    // For OSU!, the game reads the absolute cursor position and
                    // the user taps the iPad screen directly (not sent over network)

                    // Update touch rate
                    _touchCount++;
                    var now = DateTime.Now;
                    if ((now - _lastTouchTime).TotalSeconds >= 1.0)
                    {
                        TouchRate = _touchCount;
                        _touchCount = 0;
                        _lastTouchTime = now;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error sending touch: {ex.Message}");
                }
            }
        }

        public void SendMouseClick(bool leftButton, bool isDown)
        {
            if (!_isInitialized)
                return;

            uint flags = 0;
            if (leftButton)
            {
                flags = isDown ? MOUSEEVENTF_LEFTDOWN : MOUSEEVENTF_LEFTUP;
            }

            if (flags != 0)
            {
                mouse_event(flags, 0, 0, 0, UIntPtr.Zero);
            }
        }

        public void Dispose()
        {
            lock (_lock)
            {
                _isInitialized = false;
            }
        }
    }
}
