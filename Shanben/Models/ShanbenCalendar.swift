import Foundation

enum ShanbenCalendar {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.timeZone = .current
        return calendar
    }

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// 当日结束：次日零点，配合半开区间 `[start, end)`。
    static func endOfDay(_ date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: startOfDay(date))!
    }

    static func startOfWeek(_ date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromSunday = weekday - 1
        return calendar.date(byAdding: .day, value: -daysFromSunday, to: startOfDay(date))!
    }

    static func endOfWeek(_ date: Date) -> Date {
        calendar.date(byAdding: .day, value: 7, to: startOfWeek(date))!
    }

    static func startOfMonth(_ date: Date) -> Date {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: parts)!
    }

    static func endOfMonth(_ date: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: startOfMonth(date))!
    }

    static func daysInMonth(_ date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }

    static func isCurrentMonth(_ date: Date, now: Date = Date()) -> Bool {
        calendar.isDate(date, equalTo: now, toGranularity: .month)
    }

    static func isFutureMonth(_ date: Date, now: Date = Date()) -> Bool {
        startOfMonth(date) > startOfMonth(now)
    }

    static func isFutureDay(_ date: Date, now: Date = Date()) -> Bool {
        startOfDay(date) > startOfDay(now)
    }

    /// 本月只算已经过到今天的天数；过去的月份才算整月。
    static func elapsedDays(in month: Date, now: Date = Date()) -> Int {
        if isFutureMonth(month, now: now) { return 0 }
        if isCurrentMonth(month, now: now) {
            return calendar.component(.day, from: now)
        }
        return daysInMonth(month)
    }

    static func leadingEmptyDays(in month: Date) -> Int {
        let weekday = calendar.component(.weekday, from: startOfMonth(month))
        return weekday - 1
    }

    static func date(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    static func monthTitle(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return "\(parts.year!)年\(parts.month!)月"
    }

    static func dayTitle(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year!)年\(parts.month!)月\(parts.day!)日"
    }

    static func shortDayTitle(_ date: Date) -> String {
        let parts = calendar.dateComponents([.month, .day], from: date)
        return "\(parts.month!)月\(parts.day!)日"
    }
}
