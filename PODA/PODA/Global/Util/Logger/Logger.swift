//
//  Logger.swift
//  PODA
//
//  Created by 박유경 on 2023/10/13.
//

import OSLog

enum LogLevel {
    case debug
    case info
    case warning
    case error
    case fatal
}

struct Logger {
    private static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "gjonegg")
    static func writeLog(_ level: LogLevel, message: String, isNeededStackTraceInfo : Bool = true, line : Int = #line, fileName : String = #file) {
        let logType: OSLogType
        var logMessage = ""
        var emoji = ""

        switch level {
        case .debug :
            logType = .debug
            emoji = "ℹ️"
        case .info:
            logType = .info
            emoji = "✅"
        case .warning:
            logType = .default
            emoji = "⚠️"
        case .error:
            logType = .error
            emoji = "❌"
        case .fatal:
            logType = .fault
            emoji = "🚫"
        }
        
        logMessage = "[\(Date().GetCurrentTime())] : \(emoji) : \(message) -> \(fileName.split(separator: "/").last!) :\(line)\r\n"
        
        if isNeededStackTraceInfo{
            logMessage += Thread.callStackSymbols.joined(separator: "\r\n")
        }
        
        if level == .error || level == .fatal {
            saveLog(logMessage)
        }
        
        os_log("%@", log: log, type: logType, logMessage)
    }
    
    private static func saveLog(_ logMessage: String) {
        DispatchQueue.global().async {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let currentTime = Date().GetCurrentTime(Dataforamt : "yyyy-MM-dd")
                let fileName = "error_log_\(currentTime).txt"
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                print(fileURL) // 경로 이걸로 확인
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        let fileHandle = try FileHandle(forWritingTo: fileURL)
                        fileHandle.seekToEndOfFile()

                        if let data = logMessage.data(using: .utf8) {
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    } else {
                        try logMessage.write(to: fileURL, atomically: false, encoding: .utf8)
                    }
                } catch {
                    fatalError("로그 파일 열기 또는 추가 실패: \(error)")
                }
            }
        }
    }
}
