import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = TravelViewModel()
    @State private var isDrawing = false
    @State private var showResult = false
    @State private var showConfetti = false
    @State private var boxWiggle = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 22)
                        .padding(.top, 12)

                    ZStack {
                        if let town = viewModel.currentTown, showResult {
                            ResultCardView(town: town, wikiInfo: viewModel.wikiInfo) {
                                drawOmikuji()
                            }
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.78).combined(with: .opacity).combined(with: .offset(y: 24)),
                                removal: .scale(scale: 0.96).combined(with: .opacity)
                            ))
                        } else {
                            OmikujiStandView(isDrawing: isDrawing, boxWiggle: boxWiggle) {
                                drawOmikuji()
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    footer
                        .padding(.horizontal, 18)
                        .padding(.bottom, 8)

                    BannerAdView()
                        .frame(height: 50)
                }

                if showConfetti {
                    ConfettiBurst()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .navigationTitle("トラベルおみくじ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onShake { drawOmikuji() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        drawOmikuji()
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.headline)
                            .foregroundStyle(Color(hex: "C2410C"))
                    }
                    .disabled(isDrawing)
                    .accessibilityLabel("くじを引く")
                }
            }
        }
        .environmentObject(viewModel)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日の旅先を、運まかせで。")
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .foregroundStyle(Color(hex: "2F2A1F"))
                    Text("スマホを振るか、くじ箱をタップ")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: "80674A"))
                }

                Spacer()

                if showResult {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showResult = false
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundStyle(Color(hex: "7C2D12"))
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.72), in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 1))
                    }
                    .accessibilityLabel("もう一度引く準備をする")
                }
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if !viewModel.savedTowns.isEmpty {
            NavigationLink {
                SavedListView(viewModel: viewModel)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "bookmark.fill")
                    Text("行きたいリスト")
                    Text("\(viewModel.savedTowns.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "F97316"), in: Capsule())
                }
                .font(.subheadline.bold())
                .foregroundStyle(Color(hex: "4B3524"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.95), lineWidth: 1)
                )
            }
        }
    }

    private func drawOmikuji() {
        guard !isDrawing else { return }
        isDrawing = true
        showConfetti = false
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation(.spring(response: 0.28, dampingFraction: 0.45)) {
            boxWiggle.toggle()
            showResult = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
            viewModel.drawRandom()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.58, dampingFraction: 0.72)) {
                showResult = true
                isDrawing = false
                showConfetti = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation(.easeOut(duration: 0.35)) {
                    showConfetti = false
                }
            }
        }
    }
}

private struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFF7AD"), Color(hex: "FFD6A5"), Color(hex: "A7E8F2"), Color(hex: "BDE0FE")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Sunburst()
                .fill(Color.white.opacity(0.18), style: FillStyle(eoFill: true))
                .frame(width: 520, height: 520)
                .offset(x: 140, y: -250)

            VStack {
                HStack {
                    CloudShape()
                        .fill(.white.opacity(0.52))
                        .frame(width: 150, height: 62)
                        .offset(x: -22)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    CloudShape()
                        .fill(.white.opacity(0.42))
                        .frame(width: 190, height: 78)
                        .offset(x: 36, y: -44)
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct OmikujiStandView: View {
    let isDrawing: Bool
    let boxWiggle: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 18)

            ZStack {
                ForEach(0..<7, id: \.self) { index in
                    TicketStrip(index: index, isDrawing: isDrawing)
                }

                Button(action: action) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF8A3D"), Color(hex: "F94D6A"), Color(hex: "B83280")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 235, height: 190)
                            .shadow(color: Color(hex: "B83280").opacity(0.28), radius: 26, x: 0, y: 18)

                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 176, height: 84)
                            .offset(y: -18)

                        VStack(spacing: 10) {
                            Image(systemName: isDrawing ? "wand.and.stars" : "shippingbox.fill")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(.white)
                                .symbolRenderingMode(.hierarchical)
                            Text(isDrawing ? "旅の神さまに相談中" : "くじを引く")
                                .font(.system(.title3, design: .rounded).weight(.heavy))
                                .foregroundStyle(.white)
                            Text("TAP / SHAKE")
                                .font(.caption.weight(.black))
                                .foregroundStyle(.white.opacity(0.76))
                        }
                    }
                    .rotationEffect(.degrees(isDrawing ? (boxWiggle ? 5 : -5) : 0))
                    .scaleEffect(isDrawing ? 1.03 : 1.0)
                    .animation(.easeInOut(duration: 0.12).repeatCount(isDrawing ? 6 : 1, autoreverses: true), value: boxWiggle)
                }
                .buttonStyle(.plain)
                .disabled(isDrawing)
            }
            .frame(height: 300)

            VStack(spacing: 10) {
                Text("次の休みに行く場所、ここで決めよう")
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(Color(hex: "3F2D20"))
                    .multilineTextAlignment(.center)
                Text("当たりが出たら、写真と名物つきの旅カードが開きます。")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color(hex: "7C5D42"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)
            }

            Spacer(minLength: 18)
        }
        .padding(.horizontal, 20)
    }
}

private struct TicketStrip: View {
    let index: Int
    let isDrawing: Bool

    private var xOffset: CGFloat { CGFloat(index - 3) * 28 }
    private var angle: Double { Double(index - 3) * 7 }
    private var color: Color {
        [Color(hex: "FFFFFF"), Color(hex: "FFF1F2"), Color(hex: "ECFEFF"), Color(hex: "FEF3C7")][index % 4]
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(color)
            .frame(width: 32, height: 148)
            .overlay(
                VStack(spacing: 12) {
                    Circle().fill(Color(hex: "F97316")).frame(width: 6, height: 6)
                    Text("旅")
                        .font(.headline.bold())
                        .foregroundStyle(Color(hex: "A43D18"))
                    Circle().fill(Color(hex: "0EA5E9")).frame(width: 6, height: 6)
                }
            )
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .offset(x: xOffset, y: isDrawing ? -48 - CGFloat(index % 2) * 12 : -82)
            .rotationEffect(.degrees(isDrawing ? angle + 10 : angle))
            .animation(.spring(response: 0.42, dampingFraction: 0.55).delay(Double(index) * 0.025), value: isDrawing)
    }
}

private struct ConfettiBurst: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<42, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(confettiColor(index))
                        .frame(width: CGFloat(6 + (index % 3) * 3), height: CGFloat(10 + (index % 4) * 4))
                        .rotationEffect(.degrees(Double(index * 19)))
                        .offset(
                            x: CGFloat((index * 37) % Int(max(proxy.size.width, 1))) - proxy.size.width / 2,
                            y: CGFloat((index * 53) % Int(max(proxy.size.height, 1))) - proxy.size.height / 2
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func confettiColor(_ index: Int) -> Color {
        [Color(hex: "F97316"), Color(hex: "06B6D4"), Color(hex: "F43F5E"), Color(hex: "FACC15"), Color(hex: "22C55E")][index % 5]
    }
}

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.minX, y: rect.midY - rect.height * 0.28, width: rect.width * 0.42, height: rect.height * 0.52))
        path.addEllipse(in: CGRect(x: rect.width * 0.25, y: rect.minY, width: rect.width * 0.46, height: rect.height * 0.72))
        path.addEllipse(in: CGRect(x: rect.width * 0.55, y: rect.midY - rect.height * 0.24, width: rect.width * 0.42, height: rect.height * 0.5))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.08, y: rect.midY - rect.height * 0.08, width: rect.width * 0.84, height: rect.height * 0.4), cornerSize: CGSize(width: 24, height: 24))
        return path
    }
}

private struct Sunburst: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let inner = min(rect.width, rect.height) * 0.18
        let outer = min(rect.width, rect.height) * 0.5

        for index in 0..<32 {
            let start = Double(index) * .pi / 16
            let end = start + .pi / 32
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + CGFloat(cos(start)) * inner, y: center.y + CGFloat(sin(start)) * inner))
            path.addLine(to: CGPoint(x: center.x + CGFloat(cos(end)) * outer, y: center.y + CGFloat(sin(end)) * outer))
            path.addLine(to: center)
        }
        return path
    }
}
