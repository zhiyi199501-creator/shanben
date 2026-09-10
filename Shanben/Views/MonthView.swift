import SwiftData
import SwiftUI

struct MonthView: View {
    @Query(sort: \Deed.occurredAt, order: .reverse) private var deeds: [Deed]
    @State private var month = ShanbenCalendar.startOfMonth(Date())
    @State private var selectedDay = ShanbenCalendar.startOfDay(Date())
    @State private var editor: EditorRoute?

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        monthHeader
                        statsRow
                        calendar
                        daySection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 36)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $editor) { route in
                DeedEditorView(deed: route.deed, defaultDate: selectedDay)
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                shiftMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Text(ShanbenCalendar.monthTitle(month))
                .font(Theme.body(18, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Spacer()
            Button {
                shiftMonth(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.medium))
                    .foregroundStyle(canAdvanceMonth ? Theme.ink : Theme.hairline)
                    .frame(width: 36, height: 36)
            }
            .disabled(!canAdvanceMonth)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(value: "\(monthCount)", label: "总善")
            statCard(value: "\(dayCount)", label: "天数")
            statCard(value: averageText, label: "日均")
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(Theme.body(22, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .monospacedDigit()
            Text(label)
                .font(Theme.body(12))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 2)
    }

    private var calendar: some View {
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let counts = DeedStore.countsByDay(deeds, in: month)
        let cells = makeCells()

        return VStack(spacing: 10) {
            HStack {
                ForEach(weekdays, id: \.self) { label in
                    Text(label)
                        .font(Theme.body(12))
                        .foregroundStyle(Theme.muted)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 8
            ) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day, count: counts[day] ?? 0)
                    } else {
                        Color.clear.frame(minHeight: 48)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: Int, count: Int) -> some View {
        let date = dateInMonth(day)
        let selected = ShanbenCalendar.isSameDay(date, selectedDay)
        let isToday = ShanbenCalendar.isSameDay(date, Date())

        return Button {
            selectedDay = date
        } label: {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(Theme.body(15, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? Color.white : Theme.ink)
                    .frame(width: 32, height: 32)
                    .background {
                        if selected {
                            Circle().fill(Theme.accent)
                        } else if isToday {
                            Circle().fill(Theme.accentSoft)
                        }
                    }
                Text(count > 0 ? "\(count)" : " ")
                    .font(Theme.body(11))
                    .foregroundStyle(count > 0 ? Theme.accent : Color.clear)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(day)日\(count > 0 ? "，\(count) 善" : "")\(selected ? "，已选" : "")")
    }

    private var daySection: some View {
        let dayDeeds = DeedStore.list(deeds, on: selectedDay)

        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(ShanbenCalendar.shortDayTitle(selectedDay))  ·  \(dayDeeds.count) 善")
                    .font(Theme.body(15, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Button("记一笔") {
                    editor = EditorRoute(deed: nil)
                }
                .font(Theme.body(14, weight: .medium))
                .foregroundStyle(Theme.accent)
            }
            .padding(.top, 4)
            .padding(.bottom, 12)

            if dayDeeds.isEmpty {
                Text("这一天还没有记。")
                    .font(Theme.body(15))
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 8)
            } else {
                ForEach(dayDeeds) { deed in
                    Button {
                        editor = EditorRoute(deed: deed)
                    } label: {
                        DeedRow(deed: deed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.hairline)
                            .frame(height: 0.5)
                    }
                }
            }
        }
    }

    private var monthCount: Int {
        DeedStore.count(
            deeds,
            from: ShanbenCalendar.startOfMonth(month),
            to: ShanbenCalendar.endOfMonth(month)
        )
    }

    private var dayCount: Int {
        ShanbenCalendar.elapsedDays(in: month)
    }

    private var canAdvanceMonth: Bool {
        !ShanbenCalendar.isCurrentMonth(month)
    }

    private var averageText: String {
        guard dayCount > 0 else { return "0" }
        return String(format: "%.1f", Double(monthCount) / Double(dayCount))
    }

    private func shiftMonth(_ delta: Int) {
        let next = ShanbenCalendar.calendar.date(byAdding: .month, value: delta, to: month)!
        guard !ShanbenCalendar.isFutureMonth(next) else { return }
        month = next
        if ShanbenCalendar.isCurrentMonth(month) {
            selectedDay = ShanbenCalendar.startOfDay(Date())
        } else {
            selectedDay = ShanbenCalendar.startOfMonth(month)
        }
    }

    private func makeCells() -> [Int?] {
        var cells: [Int?] = Array(repeating: nil, count: ShanbenCalendar.leadingEmptyDays(in: month))
        cells += Array(1...ShanbenCalendar.daysInMonth(month))
        while cells.count % 7 != 0 {
            cells.append(nil)
        }
        return cells
    }

    private func dateInMonth(_ day: Int) -> Date {
        let parts = ShanbenCalendar.calendar.dateComponents([.year, .month], from: month)
        return ShanbenCalendar.date(year: parts.year!, month: parts.month!, day: day)
    }
}
