import SwiftUI

struct SavedListView: View {
    @ObservedObject var viewModel: TravelViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFF7AD"), Color(hex: "FDE68A"), Color(hex: "BAE6FD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if viewModel.savedTowns.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color(hex: "F97316"))
                    Text("まだ保存した旅先はありません")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Color(hex: "3F2D20"))
                    Text("気になるカードが出たら、行きたいリストに入れておきましょう。")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: "7C5D42"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
            } else {
                List {
                    ForEach(viewModel.savedTowns) { town in
                        SavedTownRow(town: town)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: viewModel.removeSaved)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, 8)
            }
        }
        .navigationTitle("行きたいリスト")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SavedTownRow: View {
    let town: Town

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [town.fortuneColor.opacity(0.9), Color(hex: "0EA5E9").opacity(0.86)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "map.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 5) {
                Text(town.name)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Color(hex: "34251A"))
                Text([town.prefecture, town.spot].compactMap { $0 }.joined(separator: " / "))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "80674A"))
                    .lineLimit(1)
            }

            Spacer()

            Text(town.fortune)
                .font(.caption2.weight(.black))
                .foregroundStyle(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(town.fortuneColor, in: Capsule())
        }
        .padding(14)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 7)
        .padding(.vertical, 4)
    }
}
