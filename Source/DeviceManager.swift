//
//  DeviceManager.swift
//  Garmin-ExampleApp-Swift
//  1/1/2017
//
//  The following code is a fully-functional port of Garmin's iOS Example App
//  originally written in Objective-C:
//  https://developer.garmin.com/connect-iq/sdk/
//
//  More details on the Connect IQ iOS SDK can be found at:
//  https://developer.garmin.com/connect-iq/developer-tools/ios-sdk-guide/
//
//  MIT License
//
//  Copyright (c) 2017 Doug Williams - dougw@igudo.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import ConnectIQ
import UIKit

let kDevicesFileName = "devices"

protocol DeviceManagerDelegate {
    func devicesChanged()
}

class DeviceManager: NSObject {
    
    var devices = [IQDevice]()
    var delegate: DeviceManagerDelegate?
    
    static let sharedInstance = DeviceManager()
   
    private override init() {
        // no op
    }
    
    func handleOpenURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme! == ReturnURLScheme {
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
                self.delegate?.devicesChanged()
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
            self.devices.removeAll()
        }
        self.delegate!.devicesChanged()
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
        return URL.applicationSupportDirectory.appendingPathComponent(kDevicesFileName)
    }
}
