import SwiftUI
import UIKit

struct ShareDeedItem: Identifiable {
    let id: UUID
    let content: String
    let occurredAt: Date

    init(_ deed: Deed) {
        id = deed.id
        content = deed.content
        occurredAt = deed.occurredAt
    }
}

struct ShareTodayButton: View {
    let day: Date
    let deeds: [Deed]
    @Binding var payload: SharePayload?

    var body: some View {
        Button("分享") {
            present()
        }
        .font(Theme.body(14))
        .foregroundStyle(deeds.isEmpty ? Theme.hairline : Theme.ink.opacity(0.7))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(deeds.isEmpty ? Color.clear : Theme.accentSoft, in: Capsule())
        .contentShape(Rectangle())
        .disabled(deeds.isEmpty)
        .accessibilityLabel("分享")
        .buttonStyle(.plain)
    }

    private func present() {
        let items = deeds
            .map(ShareDeedItem.init)
            .sorted { $0.occurredAt < $1.occurredAt }
        let image = TodayShareCardImage.render(day: day, deeds: items)
            ?? TodayShareCardImage.placeholder(day: day, count: items.count)
        payload = SharePayload(image: image, caption: "今日 \(items.count) 善")
    }
}

struct SharePayload: Identifiable {
    let id = UUID()
    let image: UIImage
    let caption: String
}

struct SharePreviewSheet: View {
    let payload: SharePayload
    @Environment(\.dismiss) private var dismiss
    @State private var activity: ShareActivity?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.canvas.ignoresSafeArea()
                ScrollView {
                    Image(uiImage: payload.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: Color.black.opacity(0.08), radius: 16, y: 8)
                        .padding(.horizontal, 28)
                        .padding(.top, 12)
                        .padding(.bottom, 28)
                }
            }
            .navigationTitle("分享今日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    activity = ShareActivity(image: payload.image, caption: payload.caption)
                } label: {
                    Text("分享")
                        .font(Theme.body(16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.accent, in: Capsule())
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 10)
            }
            .sheet(item: $activity) { item in
                ActivityView(items: item.activityItems)
            }
        }
    }
}

private struct ShareActivity: Identifiable {
    let id = UUID()
    let image: UIImage
    let caption: String

    var activityItems: [Any] {
        if let data = image.pngData() {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("shanben-today.png")
            try? data.write(to: url, options: .atomic)
            return [url, caption]
        }
        return [image, caption]
    }
}

struct TodayShareCard: View {
    let day: Date
    let deeds: [ShareDeedItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(dayNumber)
                .font(Theme.song(72, bold: true))
                .foregroundStyle(Theme.ink)
                .padding(.bottom, 4)
            Text(weekdayLine)
                .font(Theme.body(15))
                .foregroundStyle(Theme.muted)
                .padding(.bottom, 22)

            Rectangle()
                .fill(Theme.accent.opacity(0.55))
                .frame(width: 28, height: 1.5)
                .padding(.bottom, 28)

            VStack(alignment: .leading, spacing: 22) {
                ForEach(deeds) { deed in
                    Text(deed.content)
                        .font(Theme.body(17))
                        .foregroundStyle(Theme.ink)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Color.clear.frame(height: 40)

            HStack(alignment: .lastTextBaseline) {
                Text("今日 \(deeds.count) 善")
                    .font(Theme.body(13))
                    .foregroundStyle(Theme.muted)
                Spacer(minLength: 12)
                Text("善本")
                    .font(Theme.song(16, bold: true))
                    .foregroundStyle(Theme.ink)
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 44)
        .padding(.bottom, 36)
        .frame(width: TodayShareCardImage.cardWidth, alignment: .leading)
        .frame(minHeight: TodayShareCardImage.minHeight, alignment: .topLeading)
        .background(Theme.canvas)
    }

    private var dayNumber: String {
        "\(ShanbenCalendar.calendar.component(.day, from: day))"
    }

    private var weekdayLine: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月 · EEEE"
        return formatter.string(from: day)
    }
}

enum TodayShareCardImage {
    static let cardWidth: CGFloat = 390
    static let minHeight: CGFloat = 520

    @MainActor
    static func placeholder(day: Date, count: Int) -> UIImage {
        let size = CGSize(width: cardWidth, height: minHeight)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            UIColor(Theme.canvas).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    @MainActor
    static func render(day: Date, deeds: [ShareDeedItem]) -> UIImage? {
        let card = TodayShareCard(day: day, deeds: deeds)
        if let image = renderWithImageRenderer(card) {
            return image
        }
        return renderWithHostingController(card)
    }

    @MainActor
    private static func renderWithImageRenderer(_ card: TodayShareCard) -> UIImage? {
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        renderer.proposedSize = ProposedViewSize(width: cardWidth, height: nil)
        return renderer.uiImage
    }

    @MainActor
    private static func renderWithHostingController(_ card: TodayShareCard) -> UIImage? {
        let host = UIHostingController(rootView: card)
        host.safeAreaRegions = []
        let fit = host.sizeThatFits(in: CGSize(width: cardWidth, height: 10_000))
        let size = CGSize(width: cardWidth, height: max(minHeight, fit.height))
        host.view.bounds = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = UIColor(Theme.canvas)
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
        }
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
