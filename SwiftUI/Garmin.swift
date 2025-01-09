#if !targetEnvironment(macCatalyst)
import ConnectIQ
import UIKit

class Garmin: NSObject {
    private let URLScheme = "garmin-exampleapp-swiftui"
    var devices = [IQDevice]()

    override init() {
        super.init()
        ConnectIQ.sharedInstance().initialize(withUrlScheme: URLScheme, uiOverrideDelegate: nil)
        restoreDevicesFromFileSystem()
    }

    private var devicesFileURL: URL {
        let dirExists = (try? URL.applicationSupportDirectory.checkResourceIsReachable()) ?? false
        if !dirExists {
            print("DeviceManager.devicesFilePath appSupportDirectory \(URL.applicationSupportDirectory) does not exist, creating... ")
            do {
                try FileManager.default.createDirectory(at: URL.applicationSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("There was an error creating the directory \(URL.applicationSupportDirectory) with error: \(error)")
            }
        }
        return URL.applicationSupportDirectory.appendingPathComponent("devices")
    }

    func registerDevices() {
        for device in devices {
            print("Registering for device events from '\(device.friendlyName.debugDescription)'")
            ConnectIQ.sharedInstance().register(forDeviceEvents: device, delegate: self)
        }
    }

    func handleOpenURL(_ url: URL) -> Bool {
        if url.scheme! == URLScheme {
            let devices = ConnectIQ.sharedInstance().parseDeviceSelectionResponse(from: url)
            dump(devices)
            if let devices, !devices.isEmpty {
                print("Forgetting \(Int(self.devices.count)) known devices.")
                self.devices.removeAll()
                for (index, device) in devices.enumerated() {
                    guard let device = device as? IQDevice else { continue }
                    print("Received device (\(index + 1) of \(devices.count): [\(device.uuid.debugDescription), \(device.modelName.debugDescription), \(device.friendlyName.debugDescription)]")
                    self.devices.append(device)
                    print("status>>> \(ConnectIQ.sharedInstance().getDeviceStatus(device).rawValue)")
                }
                self.saveDevicesToFileSystem()
                registerDevices()
                return true
            }
        }
        return false
    }

    func saveDevicesToFileSystem() {
        print("Saving known devices.")
        do {
            try NSKeyedArchiver.archivedData(withRootObject: devices, requiringSecureCoding: false).write(to: devicesFileURL)
        } catch {
            print("Failed to save devices file.")
        }
    }

    func restoreDevicesFromFileSystem() {
        guard let restoredDevices = NSKeyedUnarchiver.unarchiveObject(withFile: self.devicesFileURL.absoluteString) as? [IQDevice] else {
            print("No device restoration file found.")
            return
        }

        if !restoredDevices.isEmpty {
            print("Restored saved devices:")
            for device in restoredDevices {
                print("\(device)")
            }
            self.devices = restoredDevices
        } else {
            print("No saved devices to restore.")
            devices.removeAll()
        }
        registerDevices()
    }
}

extension Garmin: IQDeviceEventDelegate {
    func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus) {
        print("Device status changed: \(status)")
    }
}

#endif
