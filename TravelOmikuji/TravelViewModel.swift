import SwiftUI

class WikiInfo: ObservableObject {
    @Published var description: String?
    @Published var imageURL: URL?
}

class TravelViewModel: ObservableObject {
    @Published var currentTown: Town?
    @Published var wikiInfo = WikiInfo()
    @Published var savedTowns: [Town] = []

    private var towns: [Town] = []

    init() {
        loadTowns()
        loadSaved()
    }

    func drawRandom() {
        guard !towns.isEmpty else { return }
        let town = towns.randomElement()!
        currentTown = town
        wikiInfo = WikiInfo()
        fetchWikiInfo(for: town)
    }

    func toggleSave(_ town: Town) {
        if let idx = savedTowns.firstIndex(where: { $0.id == town.id }) {
            savedTowns.remove(at: idx)
        } else {
            savedTowns.append(town)
        }
        persistSaved()
    }

    func isSaved(_ town: Town) -> Bool {
        savedTowns.contains(where: { $0.id == town.id })
    }

    func removeSaved(at offsets: IndexSet) {
        savedTowns.remove(atOffsets: offsets)
        persistSaved()
    }

    private func loadTowns() {
        guard let url = Bundle.main.url(forResource: "towns", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        towns = (try? JSONDecoder().decode([Town].self, from: data)) ?? []
    }

    private func fetchWikiInfo(for town: Town) {
        let query = "\(town.name) \(town.prefecture)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "https://ja.wikipedia.org/api/rest_v1/page/summary/\(town.name)"
        guard let url = URL(string: urlStr) else { return }

        var request = URLRequest(url: url)
        request.setValue("TravelOmikuji/1.0 (iOS App)", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            DispatchQueue.main.async {
                self?.wikiInfo.description = json["extract"] as? String
                if let thumb = json["thumbnail"] as? [String: Any],
                   let src = thumb["source"] as? String {
                    self?.wikiInfo.imageURL = URL(string: src)
                } else if let orig = json["originalimage"] as? [String: Any],
                          let src = orig["source"] as? String {
                    self?.wikiInfo.imageURL = URL(string: src)
                }
            }
        }.resume()
    }

    private var savedURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("saved_towns.json")
    }

    private func loadSaved() {
        guard let data = try? Data(contentsOf: savedURL) else { return }
        savedTowns = (try? JSONDecoder().decode([Town].self, from: data)) ?? []
    }

    private func persistSaved() {
        let data = try? JSONEncoder().encode(savedTowns)
        try? data?.write(to: savedURL)
    }
}
