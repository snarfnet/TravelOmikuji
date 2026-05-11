import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

@main
struct TravelOmikujiApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var attRequested = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) {
                    if scenePhase == .active && !attRequested {
                        attRequested = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            ATTrackingManager.requestTrackingAuthorization { _ in
                                DispatchQueue.main.async {
                                    GADMobileAds.sharedInstance().start { _ in }
                                }
                            }
                        }
                    }
                }
        }
    }
}
