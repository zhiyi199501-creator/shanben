import SwiftUI
import UIKit

struct RootTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.tabBarUIColor
        appearance.shadowColor = UIColor(white: 0, alpha: 0.06)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("今日", systemImage: "square.and.pencil") }
            MonthView()
                .tabItem { Label("本月", systemImage: "calendar") }
        }
        .tint(Theme.accent)
    }
}
