import ConnectIQ
import SwiftUI

struct DetailView: View {
    @EnvironmentObject private var appModel: AppModel
    var device: IQDevice

    var body: some View {
        List(appModel.appInfos(for: device), id: \.app) { info in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(info.name)
                            .frame(width: 200, alignment: .leading)
                        Text(info.installedText)
                            .font(.caption)
                    }
                    Button {
                        ConnectIQ.sharedInstance().showStore(for: info.app) // Useless on the Simulator
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                if !info.isInstalled {
                    Text("[Install](gcm-ciq://ui?generic)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .top)
                }
            }
        }
        .navigationTitle(device.friendlyName)
    }
}

#Preview {
    NavigationStack {
        DetailView(device: IQDevice(id: UUID(), modelName: "Model", friendlyName: "Friend"))
            .environmentObject(AppModel())
    }
}
