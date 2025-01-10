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
                    openURL(URL(string: "garmin-exampleapp-swift://device-select-resp?ciqApp=Connect&ciqBundle=com.garmin.connect.mobile&ciqScheme&ciqSdkVersion=10000&sourceUrlHost&d0ID=A6230408-B526-A5D6-8929-7791342EB4AF&d0Model=fenix%205&d0Name=garsim01")!)
                }
        }
    }
}
