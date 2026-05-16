import SwiftUI

struct SettingsShortcut: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let urlScheme: String
    let manualPath: String
}

struct SettingsShortcutsView: View {
    let shortcuts: [SettingsShortcut] = [
        SettingsShortcut(
            title: "Almacenamiento del iPhone",
            subtitle: "Ve qué apps ocupan más espacio",
            icon: "internaldrive.fill",
            color: .blue,
            urlScheme: "App-Prefs:root=CASTLE",
            manualPath: "Ajustes → General → Almacenamiento del iPhone"
        ),
        SettingsShortcut(
            title: "Borrar datos de Safari",
            subtitle: "Elimina historial, cookies y caché",
            icon: "safari.fill",
            color: .blue,
            urlScheme: "App-Prefs:root=SAFARI",
            manualPath: "Ajustes → Safari → Borrar historial y datos"
        ),
        SettingsShortcut(
            title: "Actualización en segundo plano",
            subtitle: "Controla qué apps se actualizan en background",
            icon: "repeat.circle.fill",
            color: .orange,
            urlScheme: "App-Prefs:root=BACKGROUND_APP_REFRESH",
            manualPath: "Ajustes → General → Actualización en segundo plano"
        ),
        SettingsShortcut(
            title: "Batería y bajo consumo",
            subtitle: "Activa modo bajo consumo o revisa el uso",
            icon: "battery.100.bolt",
            color: .green,
            urlScheme: "App-Prefs:root=BATTERY_USAGE",
            manualPath: "Ajustes → Batería"
        ),
        SettingsShortcut(
            title: "Notificaciones",
            subtitle: "Desactiva las innecesarias para ahorrar RAM",
            icon: "bell.fill",
            color: .red,
            urlScheme: "App-Prefs:root=NOTIFICATIONS_ID",
            manualPath: "Ajustes → Notificaciones"
        ),
        SettingsShortcut(
            title: "Privacidad y seguimiento",
            subtitle: "Controla qué apps te rastrean",
            icon: "hand.raised.fill",
            color: .purple,
            urlScheme: "App-Prefs:root=Privacy",
            manualPath: "Ajustes → Privacidad y seguridad"
        ),
        SettingsShortcut(
            title: "Actualización de software",
            subtitle: "Instala la última versión de iOS",
            icon: "arrow.up.circle.fill",
            color: .teal,
            urlScheme: "App-Prefs:root=General&path=SOFTWARE_UPDATE_LINK",
            manualPath: "Ajustes → General → Actualización de software"
        ),
        SettingsShortcut(
            title: "Accesibilidad / Reducir movimiento",
            subtitle: "Hace el iPhone más fluido visualmente",
            icon: "waveform.path",
            color: .indigo,
            urlScheme: "App-Prefs:root=ACCESSIBILITY",
            manualPath: "Ajustes → Accesibilidad → Movimiento"
        ),
        SettingsShortcut(
            title: "Restablecer ajustes de red",
            subtitle: "Soluciona problemas de WiFi o datos lentos",
            icon: "wifi.exclamationmark",
            color: .gray,
            urlScheme: "App-Prefs:root=General&path=Reset",
            manualPath: "Ajustes → General → Transferir o restablecer → Restablecer ajustes de red"
        ),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    InfoBanner(
                        icon: "info.circle",
                        title: "Accesos directos",
                        message: "Toca cualquier opción para ir directamente a ese ajuste del sistema. Si no abre, usa la ruta manual indicada.",
                        color: .blue
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)

                    ForEach(shortcuts) { shortcut in
                        ShortcutCard(shortcut: shortcut)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Ajustes rápidos")
        }
    }
}

struct ShortcutCard: View {
    let shortcut: SettingsShortcut
    @State private var tapped = false

    var body: some View {
        Button(action: openSettings) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(shortcut.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: shortcut.icon)
                        .font(.title3)
                        .foregroundColor(shortcut.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(shortcut.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text(shortcut.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(shortcut.manualPath)
                        .font(.caption2)
                        .foregroundColor(shortcut.color)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(tapped ? shortcut.color.opacity(0.08) : Color(.secondarySystemBackground))
            .cornerRadius(14)
            .animation(.easeInOut(duration: 0.15), value: tapped)
        }
        .buttonStyle(.plain)
    }

    private func openSettings() {
        tapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { tapped = false }

        if let url = URL(string: shortcut.urlScheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
