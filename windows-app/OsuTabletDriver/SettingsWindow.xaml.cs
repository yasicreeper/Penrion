using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Animation;
using System.Windows.Threading;
using Newtonsoft.Json;

namespace OsuTabletDriver
{
    public partial class SettingsWindow : Window
    {
        private readonly ConnectionServer _server;
        private DispatcherTimer? _settingsDebounceTimer;
        private bool _isUpdatingFromServer = false;

        public SettingsWindow(ConnectionServer server)
        {
            InitializeComponent();
            _server = server;

            // Subscribe to settings updates from iPad
            _server.SettingsReceived += OnSettingsReceivedFromiPad;

            // Initialize debounce timer (wait 0.8 seconds after last change)
            _settingsDebounceTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(800)
            };
            _settingsDebounceTimer.Tick += SendSettingsToPad;

            // Load current settings if available
            LoadDefaultSettings();
        }

        private void LoadDefaultSettings()
        {
            // Set defaults
            TouchRateSlider.Value = 120;
            ActiveAreaWidthSlider.Value = 1.0;
            ActiveAreaHeightSlider.Value = 1.0;
            PressureSensitivitySlider.Value = 1.0;
            
            PerformanceModeCheck.IsChecked = true;
            VeryLowLatencyCheck.IsChecked = true;
            LowLatencyCheck.IsChecked = true;
            VisualFeedbackCheck.IsChecked = true;
            KeepScreenOnCheck.IsChecked = true;

            StreamQualityCombo.SelectedIndex = 0; // Very Low
            PressureCurveCombo.SelectedIndex = 0; // Linear
        }

        private void OnSettingChanged(object sender, RoutedEventArgs e)
        {
            if (_isUpdatingFromServer) return; // Don't send back settings we just received

            // Reset debounce timer
            _settingsDebounceTimer?.Stop();
            _settingsDebounceTimer?.Start();

            // Show "Saving..." animation immediately
            ShowSavingAnimation();
        }

        private void OnSettingChanged(object sender, SelectionChangedEventArgs e)
        {
            if (_isUpdatingFromServer) return;
            OnSettingChanged(sender, (RoutedEventArgs)null!);
        }

        private void SendSettingsToPad(object? sender, EventArgs e)
        {
            _settingsDebounceTimer?.Stop();

            // Gather all settings
            var settings = new
            {
                type = "settings",
                touchRate = (int)TouchRateSlider.Value,
                activeAreaWidth = ActiveAreaWidthSlider.Value,
                activeAreaHeight = ActiveAreaHeightSlider.Value,
                showActiveArea = ShowActiveAreaCheck.IsChecked == true,
                pressureSensitivity = PressureSensitivitySlider.Value,
                pressureCurve = (PressureCurveCombo.SelectedItem as ComboBoxItem)?.Tag?.ToString() ?? "Linear",
                streamQuality = (StreamQualityCombo.SelectedItem as ComboBoxItem)?.Tag?.ToString() ?? "Very Low (144p)",
                lowLatencyMode = LowLatencyCheck.IsChecked == true,
                performanceMode = PerformanceModeCheck.IsChecked == true,
                veryLowLatencyMode = VeryLowLatencyCheck.IsChecked == true,
                batterySaver = BatterySaverCheck.IsChecked == true,
                visualFeedback = VisualFeedbackCheck.IsChecked == true,
                hapticFeedback = HapticFeedbackCheck.IsChecked == true,
                soundEffects = SoundEffectsCheck.IsChecked == true,
                blackScreenMode = BlackScreenModeCheck.IsChecked == true,
                fullscreenMode = FullscreenModeCheck.IsChecked == true,
                keepScreenOn = KeepScreenOnCheck.IsChecked == true,
                alwaysOnDisplay = AlwaysOnDisplayCheck.IsChecked == true,
                targetFPS = VeryLowLatencyCheck.IsChecked == true ? 144 : (PerformanceModeCheck.IsChecked == true ? 120 : 90),
                jpegQuality = GetJPEGQuality((StreamQualityCombo.SelectedItem as ComboBoxItem)?.Tag?.ToString() ?? "Very Low (144p)")
            };

            // Send to iPad via server
            _server.SendSettingsToiPad(settings);

            // Show success animation (MINIMUM 0.5 seconds as requested)
            ShowSuccessAnimation();
        }

        private int GetJPEGQuality(string quality)
        {
            if (quality.Contains("Very Low")) return 30;
            if (quality.Contains("Low")) return 50;
            if (quality.Contains("Medium")) return 75;
            if (quality.Contains("High")) return 85;
            if (quality.Contains("Ultra")) return 95;
            return 30;
        }

        private void ShowSavingAnimation()
        {
            // Hide success panel
            SuccessPanel.Visibility = Visibility.Collapsed;

            // Show saving animation
            SavingProgressBar.Visibility = Visibility.Visible;
            SavingText.Visibility = Visibility.Visible;

            // Fade in animation (0.3 seconds)
            var fadeIn = new DoubleAnimation(0, 1, TimeSpan.FromSeconds(0.3));
            SavingProgressBar.BeginAnimation(OpacityProperty, fadeIn);
            SavingText.BeginAnimation(OpacityProperty, fadeIn);
        }

        private void ShowSuccessAnimation()
        {
            // Fade out saving animation (0.3 seconds)
            var fadeOut = new DoubleAnimation(1, 0, TimeSpan.FromSeconds(0.3));
            fadeOut.Completed += (s, e) =>
            {
                SavingProgressBar.Visibility = Visibility.Collapsed;
                SavingText.Visibility = Visibility.Collapsed;

                // Show success panel
                SuccessPanel.Visibility = Visibility.Visible;
                SuccessPanel.Opacity = 0;

                // Fade in success message (0.4 seconds)
                var fadeInSuccess = new DoubleAnimation(0, 1, TimeSpan.FromSeconds(0.4));
                SuccessPanel.BeginAnimation(OpacityProperty, fadeInSuccess);

                // Keep success message visible for 2 seconds, then fade out (0.5 seconds)
                var hideTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(2) };
                hideTimer.Tick += (sender, args) =>
                {
                    hideTimer.Stop();
                    var fadeOutSuccess = new DoubleAnimation(1, 0, TimeSpan.FromSeconds(0.5));
                    fadeOutSuccess.Completed += (s2, e2) =>
                    {
                        SuccessPanel.Visibility = Visibility.Collapsed;
                    };
                    SuccessPanel.BeginAnimation(OpacityProperty, fadeOutSuccess);
                };
                hideTimer.Start();
            };

            SavingProgressBar.BeginAnimation(OpacityProperty, fadeOut);
            SavingText.BeginAnimation(OpacityProperty, fadeOut);
        }

        private void OnSettingsReceivedFromiPad(object? sender, dynamic settings)
        {
            // Update UI from iPad settings (without triggering send back)
            _isUpdatingFromServer = true;

            Dispatcher.Invoke(() =>
            {
                try
                {
                    if (settings.touchRate != null)
                        TouchRateSlider.Value = (double)settings.touchRate;
                    
                    if (settings.activeAreaWidth != null)
                        ActiveAreaWidthSlider.Value = (double)settings.activeAreaWidth;
                    
                    if (settings.activeAreaHeight != null)
                        ActiveAreaHeightSlider.Value = (double)settings.activeAreaHeight;
                    
                    if (settings.pressureSensitivity != null)
                        PressureSensitivitySlider.Value = (double)settings.pressureSensitivity;
                    
                    if (settings.performanceMode != null)
                        PerformanceModeCheck.IsChecked = (bool)settings.performanceMode;
                    
                    if (settings.veryLowLatencyMode != null)
                        VeryLowLatencyCheck.IsChecked = (bool)settings.veryLowLatencyMode;
                    
                    if (settings.batterySaver != null)
                        BatterySaverCheck.IsChecked = (bool)settings.batterySaver;
                    
                    // ... (update all other settings)
                }
                finally
                {
                    _isUpdatingFromServer = false;
                }
            });
        }

        private void ResetToDefaults_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show(
                "Reset all settings to default values?\n\nThis will affect the iPad app immediately.",
                "Reset Settings",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question
            );

            if (result == MessageBoxResult.Yes)
            {
                LoadDefaultSettings();
                SendSettingsToPad(null, EventArgs.Empty);
            }
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        protected override void OnClosed(EventArgs e)
        {
            _settingsDebounceTimer?.Stop();
            _server.SettingsReceived -= OnSettingsReceivedFromiPad;
            base.OnClosed(e);
        }
    }
}
