import ConnectIQ
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            for device: IQDevice in appModel.garmin.devices {
                print("Registering for device events from '\(device.friendlyName.debugDescription)'")
                ConnectIQ.sharedInstance().register(forDeviceEvents: device, delegate: appModel.garmin)
            }
        }
    }
}

#Preview {
    ContentView()
}
