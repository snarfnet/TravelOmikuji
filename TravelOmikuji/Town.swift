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
        return fortunes[stableIndex % fortunes.count]
    }

    var fortuneColor: Color {
        switch fortune {
        case "大吉旅": return Color(hex: "F43F5E")
        case "中吉旅": return Color(hex: "F97316")
        case "小吉旅": return Color(hex: "22C55E")
        case "吉旅": return Color(hex: "0EA5E9")
        default: return Color(hex: "8B5CF6")
        }
    }

    private var stableIndex: Int {
        id.unicodeScalars.reduce(0) { partial, scalar in
            abs((partial &* 31) &+ Int(scalar.value))
        }
    }
}
