import SwiftUI

struct Tip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let category: String
}

struct TipsView: View {
    @State private var selectedCategory = "Todos"

    let categories = ["Todos", "Memoria", "Almacenamiento", "Batería", "Velocidad"]

    let tips: [Tip] = [
        Tip(title: "Reinicia el iPhone periódicamente",
            description: "Reiniciar el dispositivo una vez a la semana limpia la RAM y soluciona pequeños problemas del sistema. Mantén presionado el botón lateral y el de volumen.",
            icon: "arrow.clockwise.circle.fill",
            color: .blue,
            category: "Memoria"),

        Tip(title: "Cierra apps que ya no usas",
            description: "Desliza hacia arriba en el App Switcher para cerrar apps que consumen RAM en segundo plano, especialmente mapas, cámaras y redes sociales.",
            icon: "xmark.app.fill",
            color: .red,
            category: "Memoria"),

        Tip(title: "Limpia Safari regularmente",
            description: "Ve a Ajustes → Safari → Borrar historial y datos de sitios web. Esto libera espacio y elimina cookies acumuladas.",
            icon: "safari.fill",
            color: .blue,
            category: "Almacenamiento"),

        Tip(title: "Descarga o elimina apps poco usadas",
            description: "Ve a Ajustes → General → Almacenamiento del iPhone. Verás qué apps ocupan más espacio. Puedes 'descargar' para conservar los datos.",
            icon: "arrow.down.app.fill",
            color: .green,
            category: "Almacenamiento"),

        Tip(title: "Activa Modo de bajo consumo",
            description: "Ve a Ajustes → Batería → Modo de bajo consumo. Reduce procesos en segundo plano y prolonga la batería, lo que también puede mejorar la fluidez.",
            icon: "bolt.fill",
            color: .yellow,
            category: "Batería"),

        Tip(title: "Desactiva actualización en segundo plano",
            description: "Ve a Ajustes → General → Actualización en segundo plano. Desactívalo globalmente o app por app para ahorrar RAM y batería.",
            icon: "repeat.circle.fill",
            color: .orange,
            category: "Memoria"),

        Tip(title: "Libera espacio de fotos",
            description: "Activa iCloud Fotos y elige 'Optimizar almacenamiento del iPhone'. Las fotos en alta resolución se guardan en la nube y el iPhone mantiene versiones ligeras.",
            icon: "photo.on.rectangle.angled",
            color: .purple,
            category: "Almacenamiento"),

        Tip(title: "Gestiona las notificaciones",
            description: "Ve a Ajustes → Notificaciones. Desactiva las de apps que no necesitas. Menos notificaciones = menos procesos en segundo plano.",
            icon: "bell.slash.fill",
            color: .gray,
            category: "Velocidad"),

        Tip(title: "Actualiza iOS",
            description: "Las actualizaciones de iOS incluyen mejoras de rendimiento y correcciones. Ve a Ajustes → General → Actualización de software.",
            icon: "arrow.up.circle.fill",
            color: .green,
            category: "Velocidad"),

        Tip(title: "Reduce los efectos de movimiento",
            description: "Ve a Ajustes → Accesibilidad → Movimiento → Reducir movimiento. El iPhone se sentirá más rápido al navegar entre apps.",
            icon: "waveform.path.ecg",
            color: .teal,
            category: "Velocidad"),

        Tip(title: "Resetea ajustes de red",
            description: "Si el WiFi o datos van lentos: Ajustes → General → Transferir o restablecer → Restablecer → Ajustes de red. No borra tus datos.",
            icon: "wifi.exclamationmark",
            color: .red,
            category: "Velocidad"),

        Tip(title: "Borra mensajes antiguos",
            description: "Los mensajes con fotos y videos acumulan mucho espacio. En Mensajes, mantén presionada una conversación y elimina las más antiguas.",
            icon: "message.fill",
            color: .green,
            category: "Almacenamiento"),
    ]

    var filteredTips: [Tip] {
        if selectedCategory == "Todos" { return tips }
        return tips.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat)
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? Color.blue : Color(.secondarySystemBackground))
                                    .foregroundColor(selectedCategory == cat ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Consejos")
        }
    }
}

struct TipCard: View {
    let tip: Tip
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(tip.color.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: tip.icon)
                            .font(.title3)
                            .foregroundColor(tip.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Text(tip.category)
                            .font(.caption)
                            .foregroundColor(tip.color)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}
