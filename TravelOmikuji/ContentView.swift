import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TravelViewModel()
    @State private var isShaking = false
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if let town = viewModel.currentTown, showResult {
                        ResultCardView(town: town, wikiInfo: viewModel.wikiInfo)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.5).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else {
                        ShakePromptView(isShaking: isShaking)
                    }

                    Spacer()

                    // Saved list button
                    if !viewModel.savedTowns.isEmpty {
                        NavigationLink {
                            SavedListView(viewModel: viewModel)
                        } label: {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                Text("行きたいリスト (\(viewModel.savedTowns.count))")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(.white.opacity(0.2)))
                        }
                        .padding(.bottom, 8)
                    }

                    BannerAdView()
                        .frame(height: 50)
                }
            }
            .navigationTitle("旅行先おみくじ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .onShake {
                drawOmikuji()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        drawOmikuji()
                    } label: {
                        Image(systemName: "dice.fill")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if showResult {
                        Button {
                            withAnimation { showResult = false }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .environmentObject(viewModel)
    }

    private func drawOmikuji() {
        isShaking = true
        withAnimation(.spring(response: 0.4)) {
            showResult = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.drawRandom()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showResult = true
                isShaking = false
            }
        }
    }
}

struct ShakePromptView: View {
    let isShaking: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
                .rotationEffect(.degrees(isShaking ? -10 : 10))
                .animation(.easeInOut(duration: 0.1).repeatCount(6), value: isShaking)

            Text("スマホを振って\n旅行先を引こう！")
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("またはサイコロボタンをタップ")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))

            Spacer()
        }
        .padding()
    }
}
