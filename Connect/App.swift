import SwiftUI

@main
struct Garmin_Connect_Simulator: App {
    @State var text = "Garmin Connect Simulator"
    @AppStorage("swiftUI") var swiftUI = true
    @Environment(\.openURL) private var openURL

    var body: some Scene {
        WindowGroup {
            Toggle("SwiftUI", isOn: $swiftUI)
                .font(.largeTitle)
                .padding(100)
                .onOpenURL {
                    text = $0.absoluteString
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        openURL(
                            URL(
                                string: "garmin-exampleapp-swift\(swiftUI ? "ui" : "")://device-select-resp?ciqApp=Connect&ciqBundle=com.garmin.connect.mobile&ciqScheme&ciqSdkVersion=10000&sourceUrlHost&d0ID=A6230408-B526-A5D6-8929-7791342EB4AF&d0Model=fenix%205&d0Name=garsim01"
                            )!
                        )
                    }
                }
        }
    }
}
