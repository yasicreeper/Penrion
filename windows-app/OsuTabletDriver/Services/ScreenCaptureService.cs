using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace OsuTabletDriver
{
    public class ScreenCaptureService : IDisposable
    {
        private bool _isCapturing = false;
        private NetworkStream? _stream;
        private CancellationTokenSource? _cts;
        private int _currentFps = 0;
        private int _targetFps = 60;
        private int _quality = 75; // JPEG quality
        private readonly object _settingsLock = new object();
        
        // New: dynamic max output size (default to 960x540)
        private int _maxWidth = 960;
        private int _maxHeight = 540;
        
        public int CurrentFps => _currentFps;

        public void SetTargetFPS(int fps)
        {
            lock (_settingsLock)
            {
                _targetFps = Math.Clamp(fps, 15, 120);
                Console.WriteLine($"📹 Target FPS set to: {_targetFps}");
            }
        }

        public void SetQuality(int quality)
        {
            lock (_settingsLock)
            {
                _quality = Math.Clamp(quality, 10, 100);
                Console.WriteLine($"🎨 JPEG Quality set to: {_quality}");
            }
        }
        
        public void SetMaxDimensions(int width, int height)
        {
            lock (_settingsLock)
            {
                _maxWidth = Math.Clamp(width, 320, 3840);
                _maxHeight = Math.Clamp(height, 240, 2160);
                Console.WriteLine($"🖼️ Max stream size set to: {_maxWidth}x{_maxHeight}");
            }
        }

        // Win32 API for getting screen dimensions
        [DllImport("user32.dll")]
        private static extern int GetSystemMetrics(int nIndex);

        private const int SM_CXSCREEN = 0;
        private const int SM_CYSCREEN = 1;

        public void StartCapture(NetworkStream stream)
        {
            if (_isCapturing)
                return;

            _isCapturing = true;
            _stream = stream;
            _cts = new CancellationTokenSource();

            Task.Run(() => CaptureLoop(_cts.Token));
        }

        public void StopCapture()
        {
            _isCapturing = false;
            _cts?.Cancel();
        }

        private async Task CaptureLoop(CancellationToken token)
        {
            int frameCount = 0;
            DateTime lastFpsUpdate = DateTime.Now;
            
            try
            {
                while (!token.IsCancellationRequested && _isCapturing)
                {
                    var frameStart = DateTime.Now;
                    
                    int currentTargetFps;
                    int currentQuality;
                    int currentMaxWidth;
                    int currentMaxHeight;
                    lock (_settingsLock)
                    {
                        currentTargetFps = _targetFps;
                        currentQuality = _quality;
                        currentMaxWidth = _maxWidth;
                        currentMaxHeight = _maxHeight;
                    }
                    
                    int frameDelay = 1000 / currentTargetFps;

                    // Capture screen
                    using (var bitmap = CaptureScreen())
                    {
                        // Encode as JPEG
                        using (var ms = new MemoryStream())
                        {
                            // Resize based on current settings
                            using (var resized = ResizeBitmap(bitmap, currentMaxWidth, currentMaxHeight))
                            {
                                var encoder = ImageCodecInfo.GetImageEncoders()[1]; // JPEG
                                var encoderParams = new EncoderParameters(1);
                                encoderParams.Param[0] = new EncoderParameter(
                                    System.Drawing.Imaging.Encoder.Quality,
                                    currentQuality
                                );
                                resized.Save(ms, encoder, encoderParams);
                            }

                            byte[] imageBytes = ms.ToArray();
                            string base64 = Convert.ToBase64String(imageBytes);

                            // Send frame
                            var message = new
                            {
                                type = "screen_frame",
                                image = base64,
                                timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
                            };

                            string json = JsonConvert.SerializeObject(message);
                            byte[] jsonBytes = Encoding.UTF8.GetBytes(json);

                            // Send length prefix
                            byte[] length = BitConverter.GetBytes(jsonBytes.Length);
                            if (BitConverter.IsLittleEndian)
                                Array.Reverse(length);

                            await _stream!.WriteAsync(length, 0, 4, token);
                            await _stream.WriteAsync(jsonBytes, 0, jsonBytes.Length, token);
                            await _stream.FlushAsync(token);
                        }
                    }

                    // Update FPS
                    frameCount++;
                    if ((DateTime.Now - lastFpsUpdate).TotalSeconds >= 1.0)
                    {
                        _currentFps = frameCount;
                        frameCount = 0;
                        lastFpsUpdate = DateTime.Now;
                    }

                    // Frame rate limiting
                    var elapsed = (DateTime.Now - frameStart).TotalMilliseconds;
                    int sleepTime = Math.Max(0, frameDelay - (int)elapsed);
                    if (sleepTime > 0)
                        await Task.Delay(sleepTime, token);
                }
            }
            catch (Exception ex) when (!token.IsCancellationRequested)
            {
                Console.WriteLine($"Capture error: {ex.Message}");
            }
        }

        private Bitmap CaptureScreen()
        {
            try
            {
                // Get screen dimensions using Win32 API
                int screenWidth = GetSystemMetrics(SM_CXSCREEN);
                int screenHeight = GetSystemMetrics(SM_CYSCREEN);

                if (screenWidth <= 0 || screenHeight <= 0)
                {
                    // Fallback to default size
                    screenWidth = 1920;
                    screenHeight = 1080;
                }

                var bitmap = new Bitmap(screenWidth, screenHeight);

                using (var graphics = Graphics.FromImage(bitmap))
                {
                    graphics.CopyFromScreen(
                        0,
                        0,
                        0,
                        0,
                        new Size(screenWidth, screenHeight),
                        CopyPixelOperation.SourceCopy
                    );
                }

                return bitmap;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Screen capture error: {ex.Message}");
                // Return a blank bitmap on error
                return new Bitmap(1920, 1080);
            }
        }

        private Bitmap ResizeBitmap(Bitmap original, int maxWidth, int maxHeight)
        {
            // Calculate aspect ratio
            double ratioX = (double)maxWidth / original.Width;
            double ratioY = (double)maxHeight / original.Height;
            double ratio = Math.Min(ratioX, ratioY);

            int newWidth = (int)(original.Width * ratio);
            int newHeight = (int)(original.Height * ratio);

            // Don't upscale
            if (newWidth >= original.Width || newHeight >= original.Height)
                return new Bitmap(original);

            var resized = new Bitmap(newWidth, newHeight);
            using (var graphics = Graphics.FromImage(resized))
            {
                graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
                graphics.DrawImage(original, 0, 0, newWidth, newHeight);
            }

            return resized;
        }

        public void Dispose()
        {
            StopCapture();
            _cts?.Dispose();
        }
    }
}
