import SwiftUI

@main
struct Garmin_Connect_Simulator: App {
    @State var text = "Garmin Connect Simulator"
    @Environment(\.openURL) private var openURL

    var body: some Scene {
        WindowGroup {
            Text(text)
                .onOpenURL {
                    text = $0.absoluteString
                    openURL(URL(string: "garmin-exampleapp-swiftui://")!)
                }
        }
    }
}
