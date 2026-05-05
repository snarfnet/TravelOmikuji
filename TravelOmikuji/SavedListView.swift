import SwiftUI

struct SavedListView: View {
    @ObservedObject var viewModel: TravelViewModel

    var body: some View {
        List {
            ForEach(viewModel.savedTowns) { town in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(town.name)
                            .font(.headline)
                        Text(town.prefecture)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if let spot = town.spot {
                        Text(spot)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: viewModel.removeSaved)
        }
        .navigationTitle("行きたいリスト")
        .navigationBarTitleDisplayMode(.inline)
    }
}
