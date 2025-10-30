using System;
using System.IO;
using System.Windows;

namespace OsuTabletDriver
{
    public partial class App : Application
    {
        private ConnectionServer? _server;
        private VirtualTabletDriver? _driver;
        private ScreenCaptureService? _screenCapture;

        public App()
        {
            // Set up global exception handlers
            AppDomain.CurrentDomain.UnhandledException += OnUnhandledException;
            DispatcherUnhandledException += OnDispatcherUnhandledException;
        }

        private void OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            LogException(e.ExceptionObject as Exception);
        }

        private void OnDispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
        {
            LogException(e.Exception);
            e.Handled = true;
        }

        private void LogException(Exception? ex)
        {
            if (ex == null) return;

            try
            {
                var logPath = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
                    "OsuTabletDriver_Error.log"
                );

                var logMessage = $"[{DateTime.Now}] Exception:\n{ex.Message}\n\nStack Trace:\n{ex.StackTrace}\n\n";
                File.AppendAllText(logPath, logMessage);

                MessageBox.Show(
                    $"An error occurred:\n\n{ex.Message}\n\n" +
                    $"Error details saved to:\n{logPath}\n\n" +
                    "Please check if you're running as Administrator.",
                    "Application Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );
            }
            catch
            {
                // If logging fails, just show the error
                MessageBox.Show(
                    $"Critical Error:\n\n{ex.Message}",
                    "Application Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );
            }
        }

        private void Application_Startup(object sender, StartupEventArgs e)
        {
            try
            {
                // Check if running as administrator
                if (!IsRunAsAdministrator())
                {
                    var result = MessageBox.Show(
                        "This application requires Administrator privileges to create a virtual tablet driver.\n\n" +
                        "Please right-click the executable and select 'Run as administrator'.\n\n" +
                        "Continue anyway? (Limited functionality)",
                        "Administrator Rights Required",
                        MessageBoxButton.YesNo,
                        MessageBoxImage.Warning
                    );

                    if (result == MessageBoxResult.No)
                    {
                        Shutdown();
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                LogException(ex);
                Shutdown();
                return;
            }

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
                    $"Failed to start application:\n\n{ex.Message}\n\n" +
                    $"Stack trace:\n{ex.StackTrace}\n\n" +
                    "Make sure you're running as Administrator.",
                    "Startup Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );
                Shutdown();
            }
        }

        private bool IsRunAsAdministrator()
        {
            try
            {
                var identity = System.Security.Principal.WindowsIdentity.GetCurrent();
                var principal = new System.Security.Principal.WindowsPrincipal(identity);
                return principal.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
            }
            catch
            {
                return false;
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
