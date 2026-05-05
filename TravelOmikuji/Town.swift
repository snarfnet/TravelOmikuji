import SwiftUI

struct Town: Codable, Identifiable {
    var id: String { "\(prefecture)_\(name)" }
    let name: String
    let prefecture: String
    let specialty: String?
    let spot: String?
    let access: String?

    var fortune: String {
        let fortunes = ["大吉旅", "中吉旅", "小吉旅", "吉旅", "末吉旅"]
        let hash = abs(id.hashValue)
        return fortunes[hash % fortunes.count]
    }

    var fortuneColor: Color {
        switch fortune {
        case "大吉旅": return .red
        case "中吉旅": return .orange
        case "小吉旅": return .green
        case "吉旅": return .blue
        default: return .purple
        }
    }
}
