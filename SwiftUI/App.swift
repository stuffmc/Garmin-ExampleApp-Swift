import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var garmin = Garmin()
}

@main
struct Garmin_ExampleApp_SwiftUI: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .onOpenURL {
                    print($model.garmin.devicesChanged) // Why do I need this?!
                    print(model.garmin.handleOpenURL($0))
                    model.garmin.devicesChanged = {
                        print("GARMIN: devices changed")
                    }
                }
        }
    }
}
