// File: SimpleLogger.cs
using System;
using System.IO;

namespace MQLBridge
{
    public enum LogLevel
    {
        Debug,
        Info,
        Warning,
        Error
    }

    public static class Logger
    {
        private static string _logFilePath;
        private static string _backupFilePath;
        private static LogLevel _minimumLevel = LogLevel.Debug;
        private static readonly object _lockObject = new object();
        private static long _maxFileSize = 1024 * 1024; // 1MB default

        static Logger()
        {
            // Fixed path to C:\Temp
            string logDirectory = @"C:\Temp";

            // Ensure directory exists
            if (!Directory.Exists(logDirectory))
            {
                Directory.CreateDirectory(logDirectory);
            }

            _logFilePath = Path.Combine(logDirectory, "MQLBridge.log");
            _backupFilePath = _logFilePath + ".bak";

            Info($"Logger started. Log file: {_logFilePath}");
        }

        public static void Initialize(LogLevel minimumLevel = LogLevel.Debug, long maxFileSizeBytes = 1048576)
        {
            _minimumLevel = minimumLevel;
            _maxFileSize = maxFileSizeBytes;
        }

        public static void Debug(string message) => Log(LogLevel.Debug, message);
        public static void Info(string message) => Log(LogLevel.Info, message);
        public static void Warning(string message) => Log(LogLevel.Warning, message);
        public static void Error(string message) => Log(LogLevel.Error, message);

        public static void Error(string message, Exception ex)
        {
            Log(LogLevel.Error, $"{message}\n{ex.Message}\n{ex.StackTrace}");
        }

        private static void Log(LogLevel level, string message)
        {
            if (level < _minimumLevel)
                return;

            string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}] [{level,-7}] {message}";

            lock (_lockObject)
            {
                try
                {
                    File.AppendAllText(_logFilePath, logEntry + Environment.NewLine);
                    System.Diagnostics.Debug.WriteLine(logEntry);

                    // Check file size and rotate if needed
                    CheckAndRotateLog();
                }
                catch
                {
                    // Silently fail - logging shouldn't crash the app
                }
            }
        }

        private static void CheckAndRotateLog()
        {
            try
            {
                FileInfo fileInfo = new FileInfo(_logFilePath);
                if (fileInfo.Exists && fileInfo.Length > _maxFileSize)
                {
                    // Delete old backup if it exists
                    if (File.Exists(_backupFilePath))
                    {
                        File.Delete(_backupFilePath);
                    }

                    // Rename current log to backup
                    File.Move(_logFilePath, _backupFilePath);

                    // New log file will be created automatically on next write
                    Info("Log file rotated due to size limit");
                }
            }
            catch
            {
                // Silently fail rotation - don't crash if rotation fails
            }
        }

        public static string GetLogPath() => _logFilePath;
        public static string GetBackupPath() => _backupFilePath;
    }
}