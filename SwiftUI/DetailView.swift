import ConnectIQ
import SwiftUI

struct DetailView: View {
    @EnvironmentObject private var appModel: AppModel
    var device: IQDevice

    var body: some View {
        List(appModel.appInfos(for: device), id: \.app) { info in
            NavigationLink {
                Text(info.name)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(info.name)
                        Text(info.installedText)
                            .font(.caption)
                    }
                }
                Button {
                    ConnectIQ.sharedInstance().showStore(for: info.app)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(device: IQDevice(id: UUID(), modelName: "Model", friendlyName: "Friend"))
            .environmentObject(AppModel())
    }
}
