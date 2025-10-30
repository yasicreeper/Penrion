using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net.Sockets;
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
        
        public int CurrentFps => _currentFps;

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
            int frameDelay = 1000 / _targetFps;

            try
            {
                while (!token.IsCancellationRequested && _isCapturing)
                {
                    var frameStart = DateTime.Now;

                    // Capture screen
                    using (var bitmap = CaptureScreen())
                    {
                        // Encode as JPEG
                        using (var ms = new MemoryStream())
                        {
                            // Resize for better performance (optional)
                            using (var resized = ResizeBitmap(bitmap, 1920, 1080))
                            {
                                var encoder = ImageCodecInfo.GetImageEncoders()[1]; // JPEG
                                var encoderParams = new EncoderParameters(1);
                                encoderParams.Param[0] = new EncoderParameter(
                                    System.Drawing.Imaging.Encoder.Quality,
                                    _quality
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
            // Get primary screen dimensions
            var bounds = System.Windows.Forms.Screen.PrimaryScreen.Bounds;
            var bitmap = new Bitmap(bounds.Width, bounds.Height);

            using (var graphics = Graphics.FromImage(bitmap))
            {
                graphics.CopyFromScreen(
                    bounds.Left,
                    bounds.Top,
                    0,
                    0,
                    bounds.Size,
                    CopyPixelOperation.SourceCopy
                );
            }

            return bitmap;
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
