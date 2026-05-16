import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var storage: StorageModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header score card
                    ScoreCard(storage: storage)
                        .padding(.top, 8)

                    // Quick stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Almacenamiento libre",
                            value: storage.formattedSize(storage.freeDisk),
                            icon: "internaldrive",
                            color: storage.diskUsagePercent > 0.85 ? .red : .blue
                        )
                        StatCard(
                            title: "Temperatura",
                            value: storage.thermalStateLabel,
                            icon: "thermometer",
                            color: thermalColor
                        )
                        StatCard(
                            title: "Batería",
                            value: batteryText,
                            icon: batteryIcon,
                            color: batteryColor
                        )
                        StatCard(
                            title: "Modo bajo consumo",
                            value: storage.isLowPowerMode ? "Activo" : "Inactivo",
                            icon: "bolt.circle",
                            color: storage.isLowPowerMode ? .orange : .green
                        )
                    }
                    .padding(.horizontal)

                    // iOS memory note
                    InfoBanner(
                        icon: "info.circle",
                        title: "Sobre la RAM en iOS",
                        message: "iOS gestiona la memoria automáticamente. Las apps en segundo plano se cierran cuando el sistema lo necesita. No necesitas liberar RAM manualmente.",
                        color: .blue
                    )
                    .padding(.horizontal)

                    // Refresh button
                    Button(action: { storage.refresh() }) {
                        Label("Actualizar datos", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("iPhone Optimizer")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var batteryText: String {
        if storage.batteryLevel < 0 { return "No disponible" }
        return "\(Int(storage.batteryLevel * 100))%"
    }

    private var batteryIcon: String {
        let level = storage.batteryLevel
        if level > 0.75 { return "battery.100" }
        if level > 0.5  { return "battery.75" }
        if level > 0.25 { return "battery.50" }
        return "battery.25"
    }

    private var batteryColor: Color {
        let level = storage.batteryLevel
        if level > 0.5 { return .green }
        if level > 0.2 { return .yellow }
        return .red
    }

    private var thermalColor: Color {
        switch storage.thermalState {
        case .nominal:  return .green
        case .fair:     return .yellow
        case .serious:  return .orange
        case .critical: return .red
        @unknown default: return .gray
        }
    }
}

struct ScoreCard: View {
    let storage: StorageModel

    var healthScore: Int {
        var score = 100
        if storage.diskUsagePercent > 0.9 { score -= 30 }
        else if storage.diskUsagePercent > 0.75 { score -= 15 }
        if storage.thermalState == .serious  { score -= 15 }
        if storage.thermalState == .critical { score -= 30 }
        if storage.isLowPowerMode { score -= 5 }
        return max(score, 0)
    }

    var scoreColor: Color {
        if healthScore >= 80 { return .green }
        if healthScore >= 50 { return .orange }
        return .red
    }

    var scoreLabel: String {
        if healthScore >= 80 { return "Excelente" }
        if healthScore >= 50 { return "Regular" }
        return "Necesita atención"
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: CGFloat(healthScore) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: healthScore)
                VStack(spacing: 2) {
                    Text("\(healthScore)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                    Text("/ 100")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Text(scoreLabel)
                .font(.title2.bold())
                .foregroundColor(scoreColor)
            Text("Estado general del iPhone")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}

struct InfoBanner: View {
    let icon: String
    let title: String
    let message: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
