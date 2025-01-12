import ConnectIQ
import SwiftUI

extension IQDeviceStatus: @retroactive Identifiable, @retroactive CaseIterable {
    public static var allCases = [
        IQDeviceStatus.invalidDevice,
        .bluetoothNotReady,
        .notFound,
        .notConnected,
        .connected
    ]

    public var id: String {
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
    var devices = [IQDevice]()

#if targetEnvironment(simulator)
    @State private var status = IQDeviceStatus.connected
#else
    private var status = IQDeviceStatus.bluetoothNotReady
#endif

    var body: some View {
        List {
            Section {
                ForEach(devices, id: \.uuid) { device in
                    let status = ConnectIQ.sharedInstance().getDeviceStatus(device)
                    if status == .connected || self.status == .connected { // self.status is only for Simulator
                        NavigationLink(destination: DetailView(device: device)) {
                            view(for: device, status: status)
                        }
                    } else {
                        view(for: device, status: status)
                    }
                }
            } header: {
                if !devices.isEmpty {
                    Picker("Simulated Status", selection: $status) {
                        ForEach(IQDeviceStatus.allCases) {
                            Text($0.id)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            } footer: {
                Group {
#if targetEnvironment(simulator)
                    Text("[Find Devices](gcm-ciq://ui?device-select)") // First deploy Garmin-Connect-Simulator once!
#else
                    Button("Find Devices") {
                        ConnectIQ.sharedInstance().showDeviceSelection()
                    }
#endif
                }
                .modifier(ProminentButtonModifier())
            }
        }
        .navigationTitle("GarminUI")
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
            Spacer()
            Text(status.id)
        }
    }
}


#Preview {
    NavigationStack {
        ContentView()
            .environmentObject(AppModel())
    }
}
