import SwiftUI

struct CacheCleanerView: View {
    @EnvironmentObject var storage: StorageModel
    @State private var isCleaning = false
    @State private var showSuccess = false
    @State private var animationScale: CGFloat = 1.0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Main cleaner card
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.blue.opacity(0.2), Color.clear],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 90
                                    )
                                )
                                .frame(width: 180, height: 180)

                            if showSuccess {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.green)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Button(action: startCleaning) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: isCleaning ? [.gray, .gray.opacity(0.7)] : [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 120, height: 120)
                                            .scaleEffect(animationScale)

                                        if isCleaning {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(1.5)
                                        } else {
                                            VStack(spacing: 6) {
                                                Image(systemName: "trash.circle.fill")
                                                    .font(.system(size: 36))
                                                    .foregroundColor(.white)
                                                Text("Limpiar")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                                .disabled(isCleaning)
                            }
                        }

                        if showSuccess {
                            VStack(spacing: 6) {
                                Text("¡Limpieza completada!")
                                    .font(.title2.bold())
                                    .foregroundColor(.green)
                                Text("Se liberaron \(storage.formattedSize(storage.cacheCleanedBytes))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            VStack(spacing: 6) {
                                Text(isCleaning ? "Limpiando..." : "Limpiar caché de la app")
                                    .font(.title3.bold())
                                Text("Caché actual: \(storage.formattedSize(storage.appCacheSize))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if showSuccess {
                            Button(action: resetState) {
                                Text("Limpiar de nuevo")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .animation(.spring(), value: showSuccess)

                    // What gets cleaned
                    VStack(alignment: .leading, spacing: 14) {
                        Text("¿Qué se limpia?")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            cleanItem(icon: "photo.circle", label: "Caché de imágenes temporales", color: .orange)
                            Divider().padding(.leading, 52)
                            cleanItem(icon: "doc.circle", label: "Archivos temporales de la app", color: .blue)
                            Divider().padding(.leading, 52)
                            cleanItem(icon: "network", label: "Datos de red en caché", color: .green)
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }

                    // What cannot be cleaned
                    InfoBanner(
                        icon: "lock.circle",
                        title: "Limitación de iOS",
                        message: "Por seguridad, iOS no permite a ninguna app borrar el caché de otras apps, cookies de Safari, ni liberar RAM del sistema. Estas acciones solo se pueden hacer desde Ajustes del iPhone.",
                        color: .orange
                    )
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Limpieza")
        }
    }

    private func startCleaning() {
        isCleaning = true
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            animationScale = 0.95
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            storage.clearAppCache()
            withAnimation(.spring()) {
                isCleaning = false
                animationScale = 1.0
                showSuccess = true
            }
        }
    }

    private func resetState() {
        withAnimation {
            showSuccess = false
            storage.cacheCleaned = false
            storage.refresh()
        }
    }

    private func cleanItem(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)
            Text(label)
                .font(.body)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.caption)
        }
        .padding()
    }
}
