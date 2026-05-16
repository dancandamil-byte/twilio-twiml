import SwiftUI

struct ContentView: View {
    @StateObject private var storage = StorageModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "speedometer")
                }
                .tag(0)

            StorageView()
                .tabItem {
                    Label("Almacenamiento", systemImage: "internaldrive")
                }
                .tag(1)

            CacheCleanerView()
                .tabItem {
                    Label("Limpiar", systemImage: "trash.circle")
                }
                .tag(2)

            TipsView()
                .tabItem {
                    Label("Consejos", systemImage: "lightbulb")
                }
                .tag(3)

            SettingsShortcutsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gear")
                }
                .tag(4)
        }
        .environmentObject(storage)
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
