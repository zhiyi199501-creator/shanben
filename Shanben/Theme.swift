import SwiftUI
import UIKit

enum Theme {
    /// 近白暖灰，留白多，不再用宣纸底。
    static let canvas = Color(red: 0.965, green: 0.961, blue: 0.953)
    static let card = Color.white
    static let ink = Color(red: 0.165, green: 0.157, blue: 0.149)
    static let muted = Color(red: 0.545, green: 0.525, blue: 0.506)
    static let hairline = Color(red: 0.898, green: 0.886, blue: 0.871)
    /// 胭脂，比朱砂轻，给按钮和选中日。
    static let accent = Color(red: 0.788, green: 0.420, blue: 0.384)
    static let accentSoft = Color(red: 0.973, green: 0.929, blue: 0.918)

    static let paper = canvas
    static let page = card
    static let graphite = muted
    static let rule = hairline
    static let seal = accent
    static let todayWash = accentSoft

    static func song(_ size: CGFloat, bold: Bool = false) -> Font {
        .custom(bold ? "STSongti-SC-Bold" : "STSongti-SC-Regular", size: size)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static let tabBarUIColor = UIColor(red: 0.965, green: 0.961, blue: 0.953, alpha: 1)
}

struct PaperBackground: View {
    var body: some View {
        Theme.canvas.ignoresSafeArea()
    }
}
