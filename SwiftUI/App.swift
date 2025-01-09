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
            NavigationStack {
                ContentView()
            }
            .environmentObject(model)
            .onOpenURL {
                print("Opening \($0) — result is \(model.garmin.handleOpenURL($0))")
            }
        }
    }
}
