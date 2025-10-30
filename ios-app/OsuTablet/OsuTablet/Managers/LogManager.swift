import Foundation

class LogManager {
    static let shared = LogManager()
    
    private var logs: [LogEntry] = []
    private let maxLogs = 1000
    private let logFileURL: URL
    
    struct LogEntry {
        let timestamp: Date
        let level: LogLevel
        let category: String
        let message: String
        
        var formatted: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return "[\(formatter.string(from: timestamp))] [\(level.emoji) \(level.rawValue)] [\(category)] \(message)"
        }
    }
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case critical = "CRIT"
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🚨"
            }
        }
    }
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        logFileURL = documentsPath.appendingPathComponent("penrion_tablet.log")
        print("📝 Log file: \(logFileURL.path)")
    }
    
    func log(_ message: String, level: LogLevel = .info, category: String = "General") {
        let entry = LogEntry(timestamp: Date(), level: level, category: category, message: message)
        logs.append(entry)
        
        // Keep logs under limit
        if logs.count > maxLogs {
            logs.removeFirst(logs.count - maxLogs)
        }
        
        // Print to console
        print(entry.formatted)
        
        // Write to file (async)
        Task.detached(priority: .background) {
            await self.writeToFile(entry)
        }
    }
    
    private func writeToFile(_ entry: LogEntry) async {
        let line = entry.formatted + "\n"
        guard let data = line.data(using: .utf8) else { return }
        
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                try? fileHandle.close()
            }
        } else {
            try? data.write(to: logFileURL, options: .atomic)
        }
    }
    
    func getLogs() -> [LogEntry] {
        return logs
    }
    
    func clearLogs() {
        logs.removeAll()
        try? FileManager.default.removeItem(at: logFileURL)
        log("Logs cleared", level: .info, category: "Log")
    }
    
    func exportLogs() -> String {
        return logs.map { $0.formatted }.joined(separator: "\n")
    }
}

// Convenience functions
func logDebug(_ message: String, category: String = "General") {
    LogManager.shared.log(message, level: .debug, category: category)
}

func logInfo(_ message: String, category: String = "General") {
    LogManager.shared.log(message, level: .info, category: category)
}

func logWarning(_ message: String, category: String = "General") {
    LogManager.shared.log(message, level: .warning, category: category)
}

func logError(_ message: String, category: String = "General") {
    LogManager.shared.log(message, level: .error, category: category)
}

func logCritical(_ message: String, category: String = "General") {
    LogManager.shared.log(message, level: .critical, category: category)
}
