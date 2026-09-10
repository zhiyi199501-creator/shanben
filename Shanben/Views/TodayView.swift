import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var day = Date()

    var body: some View {
        TodayList(day: day)
            .onAppear { day = Date() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    day = Date()
                }
            }
    }
}

private struct TodayList: View {
    let day: Date
    @Query private var deeds: [Deed]
    @State private var editor: EditorRoute?
    @State private var sharePayload: SharePayload?

    init(day: Date) {
        self.day = day
        let start = ShanbenCalendar.startOfDay(day)
        let end = ShanbenCalendar.endOfDay(day)
        _deeds = Query(
            filter: #Predicate<Deed> { deed in
                deed.occurredAt >= start && deed.occurredAt < end
            },
            sort: [SortDescriptor(\.occurredAt, order: .reverse)]
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                VStack(alignment: .leading, spacing: 0) {
                    header
                    if deeds.isEmpty {
                        emptyState
                    } else {
                        deedList
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                writeButton
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(item: $editor) { route in
                DeedEditorView(deed: route.deed, defaultDate: day)
            }
            .sheet(item: $sharePayload) { payload in
                SharePreviewSheet(payload: payload)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("善本")
                    .font(Theme.song(28, bold: true))
                    .foregroundStyle(Theme.ink)
                Spacer()
                ShareTodayButton(day: day, deeds: deeds, payload: $sharePayload)
            }
            Text("今日 \(deeds.count) 善")
                .font(Theme.body(15))
                .foregroundStyle(Theme.muted)
            Text(ShanbenCalendar.dayTitle(day))
                .font(Theme.body(13))
                .foregroundStyle(Theme.muted.opacity(0.85))
        }
        .padding(.horizontal, 28)
        .padding(.top, 22)
        .padding(.bottom, 20)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今天还没有记。")
                .font(Theme.body(17))
                .foregroundStyle(Theme.ink.opacity(0.72))
            Text("做了一件对人有益的事，就记一笔。")
                .font(Theme.body(15))
                .foregroundStyle(Theme.muted)
                .lineSpacing(4)
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var deedList: some View {
        List {
            ForEach(deeds) { deed in
                Button {
                    editor = EditorRoute(deed: deed)
                } label: {
                    DeedRow(deed: deed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Theme.hairline)
                .listRowInsets(EdgeInsets(top: 16, leading: 28, bottom: 16, trailing: 28))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var writeButton: some View {
        Button {
            editor = EditorRoute(deed: nil)
        } label: {
            Text("记一笔")
                .font(Theme.body(16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Theme.accent, in: Capsule())
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 10)
    }
}

struct DeedRow: View {
    let deed: Deed

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(deed.content)
                .font(Theme.body(16))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(deed.occurredAt, format: .dateTime.hour().minute())
                .font(Theme.body(12))
                .foregroundStyle(Theme.muted)
                .monospacedDigit()
        }
    }
}

struct EditorRoute: Identifiable {
    let id = UUID()
    let deed: Deed?
}
