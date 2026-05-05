import SwiftUI
import GoogleMobileAds

@main
struct TravelOmikujiApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
