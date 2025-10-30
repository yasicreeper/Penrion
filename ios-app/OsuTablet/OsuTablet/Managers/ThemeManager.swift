import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme = .osuPink
    
    private let themeKey = "selectedTheme"
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
    }
    
    private func loadTheme() {
        if let themeName = UserDefaults.standard.string(forKey: themeKey),
           let theme = Theme(rawValue: themeName) {
            currentTheme = theme
        }
    }
}

enum Theme: String, CaseIterable, Identifiable {
    case osuPink = "OSU! Pink"
    case darkBlue = "Dark Blue"
    case neonGreen = "Neon Green"
    case purpleHaze = "Purple Haze"
    case cyberpunk = "Cyberpunk"
    case midnight = "Midnight"
    case sunset = "Sunset"
    case matrix = "Matrix"
    
    var id: String { rawValue }
    
    var backgroundColor: [Color] {
        switch self {
        case .osuPink:
            return [Color(red: 1.0, green: 0.4, blue: 0.7), Color(red: 0.8, green: 0.2, blue: 0.5)]
        case .darkBlue:
            return [Color(red: 0.1, green: 0.1, blue: 0.3), Color.black]
        case .neonGreen:
            return [Color(red: 0.0, green: 0.3, blue: 0.2), Color(red: 0.0, green: 0.1, blue: 0.1)]
        case .purpleHaze:
            return [Color(red: 0.3, green: 0.1, blue: 0.4), Color(red: 0.1, green: 0.0, blue: 0.2)]
        case .cyberpunk:
            return [Color(red: 1.0, green: 0.0, blue: 0.5), Color(red: 0.0, green: 0.8, blue: 1.0)]
        case .midnight:
            return [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.0, green: 0.0, blue: 0.05)]
        case .sunset:
            return [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 0.8, green: 0.1, blue: 0.4)]
        case .matrix:
            return [Color(red: 0.0, green: 0.2, blue: 0.0), Color.black]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .osuPink:
            return Color(red: 1.0, green: 0.4, blue: 0.7)
        case .darkBlue:
            return Color.blue
        case .neonGreen:
            return Color.green
        case .purpleHaze:
            return Color.purple
        case .cyberpunk:
            return Color.cyan
        case .midnight:
            return Color(red: 0.5, green: 0.7, blue: 1.0)
        case .sunset:
            return Color.orange
        case .matrix:
            return Color.green
        }
    }
    
    var touchColor: Color {
        switch self {
        case .osuPink:
            return Color(red: 1.0, green: 0.4, blue: 0.7)
        case .darkBlue:
            return Color.cyan
        case .neonGreen:
            return Color.green
        case .purpleHaze:
            return Color.purple
        case .cyberpunk:
            return Color.cyan
        case .midnight:
            return Color(red: 0.5, green: 0.7, blue: 1.0)
        case .sunset:
            return Color.orange
        case .matrix:
            return Color.green
        }
    }
}
