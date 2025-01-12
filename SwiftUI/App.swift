import SwiftUI
import ConnectIQ

@MainActor
final class AppModel: ObservableObject {
    @Published var garmin = Garmin()

    func appInfos(for device: IQDevice) -> [AppInfo] {
        let loopbackApp = IQApp(uuid: UUID(uuidString: "0180e520-5f7e-11e4-9803-0800200c9a66"), store: UUID(), device: device)
        let stringApp = IQApp(uuid: UUID(uuidString: "a3421fee-d289-106a-538c-b9547ab12095"), store: UUID(), device: device)
        let gameApp = IQApp(uuid: UUID(uuidString: "3bc0423d-5f82-46bb-8396-e714f608232f"), store: UUID(uuidString: "8ecc61f6-541e-45e7-b227-278a39abefd8"), device: device)

        return [
            AppInfo(name: "Loopback Test App", iqApp: loopbackApp!),
            AppInfo(name: "String Test App", iqApp: stringApp!),
            AppInfo(name: "2048 App", iqApp: gameApp!)
        ]
    }
}

@main
struct Garmin_ExampleApp_SwiftUI: App {
    @StateObject private var model = AppModel()
    @State private var devices = [IQDevice]()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(devices: devices)
            }
            .onOpenURL {
                print("Opening \($0) — result is \(model.garmin.handleOpenURL($0))")
                devices = model.garmin.devices
            }
            .environmentObject(model)
        }
    }
}
