import ConnectIQ
import SwiftUI

extension IQDeviceStatus {
    var text: String {
        switch self {
        case .invalidDevice:
            "Invalid Device"
        case .bluetoothNotReady:
            "Bluetooth Off"
        case .notFound:
            "Not Found"
        case .notConnected:
            "Not Connected"
        case .connected:
            "Connected"
        @unknown default:
            "Unknown"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        List {
            Section {
                ForEach(appModel.garmin.devices, id: \.uuid) { device in
                    let status = ConnectIQ.sharedInstance().getDeviceStatus(device)
                    if status == .connected {
                        NavigationLink(destination: Text(device.friendlyName)) {
                            view(for: device, status: status)
                        }
                    } else {
                        view(for: device, status: status)
                    }
                }
            } footer: {
                Button("Find Devices") {
                    ConnectIQ.sharedInstance().showDeviceSelection()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            appModel.garmin.registerDevices()
        }
        .onDisappear {
            ConnectIQ.sharedInstance().unregister(forAllDeviceEvents: appModel.garmin)
        }
    }

    func view(for device: IQDevice, status: IQDeviceStatus) -> some View {
        HStack {
            VStack {
                Text(device.friendlyName)
                Text(device.modelName)
                    .font(.caption)
            }
            Text(status.text)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppModel())
}
