import SwiftUI

struct ResultCardView: View {
    let town: Town
    @ObservedObject var wikiInfo: WikiInfo

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header image from Wikipedia
                if let imageURL = wikiInfo.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(height: 200)
                                .clipped()
                        default:
                            headerPlaceholder
                        }
                    }
                } else {
                    headerPlaceholder
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Town name & prefecture
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(town.prefecture)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(town.name)
                                .font(.title.bold())
                        }
                        Spacer()
                        OmikujiLabel(town: town)
                    }

                    Divider()

                    // Description from Wikipedia
                    if let desc = wikiInfo.description {
                        Text(desc)
                            .font(.body)
                            .lineLimit(5)
                    }

                    // Specialty
                    if let specialty = town.specialty {
                        InfoRow(icon: "star.fill", title: "名物", value: specialty, color: .orange)
                    }

                    // Spot
                    if let spot = town.spot {
                        InfoRow(icon: "mappin.circle.fill", title: "観光", value: spot, color: .red)
                    }

                    // Access
                    if let access = town.access {
                        InfoRow(icon: "tram.fill", title: "アクセス", value: access, color: .blue)
                    }

                    // Save button
                    HStack {
                        Spacer()
                        SaveButton(town: town)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(.regularMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }

    private var headerPlaceholder: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                           startPoint: .leading, endPoint: .trailing)
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(height: 200)
    }
}

struct OmikujiLabel: View {
    let town: Town

    var body: some View {
        Text(town.fortune)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(town.fortuneColor))
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
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
            viewModel.toggleSave(town)
            saved = viewModel.isSaved(town)
        } label: {
            HStack {
                Image(systemName: saved ? "bookmark.fill" : "bookmark")
                Text(saved ? "保存済み" : "行きたいリストに追加")
            }
            .font(.subheadline.bold())
            .foregroundColor(saved ? .orange : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(saved ? Color.orange.opacity(0.1) : Color.primary.opacity(0.05))
            )
        }
        .onAppear { saved = viewModel.isSaved(town) }
    }
}
