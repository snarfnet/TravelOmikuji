import SwiftUI

struct ResultCardView: View {
    let town: Town
    @ObservedObject var wikiInfo: WikiInfo
    let redraw: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                heroCard
                detailPanel
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
    }

    private var heroCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                headerImage
                    .frame(height: 258)
                    .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.12), .black.opacity(0.62)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        FortuneBadge(town: town)
                        Spacer()
                        Text(town.prefecture)
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color(hex: "4B3524"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(.white.opacity(0.86), in: Capsule())
                    }

                    Text(town.name)
                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                        .minimumScaleFactor(0.72)
                        .lineLimit(2)

                    Text("この旅、きっといい風が吹きます。")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(20)
            }

            HStack(spacing: 12) {
                SaveButton(town: town)

                Button(action: redraw) {
                    Image(systemName: "shuffle")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(Color(hex: "0EA5E9"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(hex: "0EA5E9").opacity(0.28), radius: 12, y: 6)
                }
                .accessibilityLabel("もう一度くじを引く")
            }
            .padding(16)
            .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.85), lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "9A3412").opacity(0.18), radius: 28, x: 0, y: 18)
    }

    private var detailPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let desc = wikiInfo.description, !desc.isEmpty {
                InfoSection(
                    icon: "text.quote",
                    title: "どんな場所？",
                    value: desc,
                    color: Color(hex: "8B5CF6")
                )
            }

            if let specialty = town.specialty {
                InfoSection(
                    icon: "fork.knife.circle.fill",
                    title: "名物",
                    value: specialty,
                    color: Color(hex: "F97316")
                )
            }

            if let spot = town.spot {
                InfoSection(
                    icon: "mappin.and.ellipse.circle.fill",
                    title: "おすすめスポット",
                    value: spot,
                    color: Color(hex: "E11D48")
                )
            }

            if let access = town.access {
                InfoSection(
                    icon: "tram.circle.fill",
                    title: "アクセス",
                    value: access,
                    color: Color(hex: "0284C7")
                )
            }
        }
        .padding(18)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.95), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var headerImage: some View {
        if let imageURL = wikiInfo.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    headerPlaceholder
                default:
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(headerGradient)
                }
            }
        } else {
            headerPlaceholder
        }
    }

    private var headerPlaceholder: some View {
        ZStack {
            headerGradient
            VStack(spacing: 14) {
                Image(systemName: "map.fill")
                    .font(.system(size: 54, weight: .bold))
                Text(town.prefecture)
                    .font(.headline.weight(.heavy))
            }
            .foregroundStyle(.white.opacity(0.92))
        }
    }

    private var headerGradient: some View {
        LinearGradient(
            colors: [Color(hex: "06B6D4"), Color(hex: "22C55E"), Color(hex: "FACC15")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct FortuneBadge: View {
    let town: Town

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
            Text(town.fortune)
        }
        .font(.caption.weight(.black))
        .foregroundStyle(.white)
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .background(town.fortuneColor, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.55), lineWidth: 1))
    }
}

private struct InfoSection: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color(hex: "8A6B4E"))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(hex: "36251A"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SaveButton: View {
    let town: Town
    @EnvironmentObject var viewModel: TravelViewModel
    @State private var saved = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                viewModel.toggleSave(town)
                saved = viewModel.isSaved(town)
            }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: saved ? "bookmark.fill" : "bookmark")
                Text(saved ? "保存済み" : "行きたいリストへ")
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(saved ? Color(hex: "9A3412") : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                saved
                ? Color(hex: "FFEDD5")
                : Color(hex: "F97316"),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(saved ? Color(hex: "FDBA74") : .white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color(hex: "F97316").opacity(saved ? 0 : 0.28), radius: 12, y: 6)
        }
        .onAppear { saved = viewModel.isSaved(town) }
        .accessibilityLabel(saved ? "保存済み" : "行きたいリストへ追加")
    }
}
