import SwiftUI

struct StorageView: View {
    @EnvironmentObject var storage: StorageModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Disk usage donut
                    DiskDonutChart(storage: storage)
                        .padding(.top, 8)

                    // Storage breakdown
                    VStack(spacing: 0) {
                        storageRow(
                            label: "Almacenamiento total",
                            value: storage.formattedSize(storage.totalDisk),
                            icon: "internaldrive",
                            color: .blue
                        )
                        Divider().padding(.leading, 52)
                        storageRow(
                            label: "Usado",
                            value: storage.formattedSize(storage.usedDisk),
                            icon: "doc.fill",
                            color: .orange
                        )
                        Divider().padding(.leading, 52)
                        storageRow(
                            label: "Disponible",
                            value: storage.formattedSize(storage.freeDisk),
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        Divider().padding(.leading, 52)
                        storageRow(
                            label: "Caché de la app",
                            value: storage.formattedSize(storage.appCacheSize),
                            icon: "trash.circle",
                            color: .gray
                        )
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Warning if low storage
                    if storage.diskUsagePercent > 0.85 {
                        InfoBanner(
                            icon: "exclamationmark.triangle.fill",
                            title: "Almacenamiento bajo",
                            message: "Tienes menos del 15% libre. Elimina apps, fotos o videos que no uses para mejorar el rendimiento.",
                            color: .red
                        )
                        .padding(.horizontal)
                    }

                    // Device info
                    VStack(spacing: 0) {
                        infoRow(label: "Dispositivo", value: storage.deviceName)
                        Divider().padding(.leading, 16)
                        infoRow(label: "iOS", value: storage.iOSVersion)
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    Button(action: { storage.refresh() }) {
                        Label("Actualizar", systemImage: "arrow.clockwise")
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
            .navigationTitle("Almacenamiento")
        }
    }

    private func storageRow(label: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body.bold())
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct DiskDonutChart: View {
    let storage: StorageModel

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 24)
                    .frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: storage.diskUsagePercent)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, storage.diskUsagePercent > 0.85 ? .red : .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 24, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: storage.diskUsagePercent)

                VStack(spacing: 2) {
                    Text("\(Int(storage.diskUsagePercent * 100))%")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                    Text("usado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 20) {
                legendItem(color: .blue, label: "Usado", value: storage.formattedSize(storage.usedDisk))
                legendItem(color: .blue.opacity(0.2), label: "Libre", value: storage.formattedSize(storage.freeDisk))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    private func legendItem(color: Color, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.caption).foregroundColor(.secondary)
                Text(value).font(.caption.bold())
            }
        }
    }
}
