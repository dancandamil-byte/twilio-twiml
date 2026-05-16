import Foundation
import UIKit

class StorageModel: ObservableObject {
    @Published var totalDisk: Int64 = 0
    @Published var usedDisk: Int64 = 0
    @Published var freeDisk: Int64 = 0
    @Published var appCacheSize: Int64 = 0
    @Published var deviceName: String = ""
    @Published var iOSVersion: String = ""
    @Published var batteryLevel: Float = 0
    @Published var thermalState: ProcessInfo.ThermalState = .nominal
    @Published var isLowPowerMode: Bool = false
    @Published var cacheCleaned: Bool = false
    @Published var cacheCleanedBytes: Int64 = 0

    init() {
        refresh()
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    func refresh() {
        fetchDiskInfo()
        fetchDeviceInfo()
        fetchAppCacheSize()
        batteryLevel = UIDevice.current.batteryLevel
        thermalState = ProcessInfo.processInfo.thermalState
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    private func fetchDiskInfo() {
        let fm = FileManager.default
        guard let attrs = try? fm.attributesOfFileSystem(forPath: NSHomeDirectory()) else { return }
        totalDisk = (attrs[.systemSize] as? Int64) ?? 0
        freeDisk  = (attrs[.systemFreeSize] as? Int64) ?? 0
        usedDisk  = totalDisk - freeDisk
    }

    private func fetchDeviceInfo() {
        deviceName  = UIDevice.current.name
        iOSVersion  = UIDevice.current.systemVersion
    }

    private func fetchAppCacheSize() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        appCacheSize = directorySize(url: cacheDir)
    }

    private func directorySize(url: URL?) -> Int64 {
        guard let url = url else { return 0 }
        var total: Int64 = 0
        if let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let fileURL as URL in enumerator {
                let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                total += Int64(size)
            }
        }
        return total
    }

    func clearAppCache() {
        let fm = FileManager.default
        guard let cacheDir = fm.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        let beforeSize = directorySize(url: cacheDir)
        if let contents = try? fm.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil) {
            for url in contents {
                try? fm.removeItem(at: url)
            }
        }
        cacheCleanedBytes = beforeSize - directorySize(url: cacheDir)
        cacheCleaned = true
        fetchAppCacheSize()
    }

    func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    var diskUsagePercent: Double {
        guard totalDisk > 0 else { return 0 }
        return Double(usedDisk) / Double(totalDisk)
    }

    var thermalStateLabel: String {
        switch thermalState {
        case .nominal:  return "Normal"
        case .fair:     return "Moderado"
        case .serious:  return "Caliente"
        case .critical: return "Crítico"
        @unknown default: return "Desconocido"
        }
    }

    var thermalStateColor: String {
        switch thermalState {
        case .nominal:  return "green"
        case .fair:     return "yellow"
        case .serious:  return "orange"
        case .critical: return "red"
        @unknown default: return "gray"
        }
    }
}
