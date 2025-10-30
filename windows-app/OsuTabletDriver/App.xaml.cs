using System;
using System.Windows;

namespace OsuTabletDriver
{
    public partial class App : Application
    {
        private ConnectionServer? _server;
        private VirtualTabletDriver? _driver;
        private ScreenCaptureService? _screenCapture;

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            try
            {
                // Initialize virtual tablet driver
                _driver = new VirtualTabletDriver();
                _driver.Initialize();

                // Initialize screen capture
                _screenCapture = new ScreenCaptureService();

                // Start connection server
                _server = new ConnectionServer(9876, _driver, _screenCapture);
                _server.Start();

                // Show main window
                MainWindow = new MainWindow(_server, _driver, _screenCapture);
                MainWindow.Show();
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Failed to start application: {ex.Message}\n\nMake sure you're running as Administrator.",
                    "Startup Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );
                Shutdown();
            }
        }

        protected override void OnExit(ExitEventArgs e)
        {
            _server?.Stop();
            _driver?.Dispose();
            _screenCapture?.Dispose();
            base.OnExit(e);
        }
    }
}
