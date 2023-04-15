import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case sunday = 1
    case monday, tuesday, wednesday, thursday, friday, saturday
}

extension WeekDay {
    var label: String {
        let label: String
        switch self {
        case .monday:
            label = "Понедельник"
        case .tuesday:
            label = "Вторник"
        case .wednesday:
            label = "Среда"
        case .thursday:
            label = "Четверг"
        case .friday:
            label = "Пятница"
        case .saturday:
            label = "Суббота"
        case .sunday:
            label = "Воскресенье"
        }
        return label
    }
    
    var shortLabel: String {
        let label: String
        
        switch self {
        case .monday:
            label = "Пн"
        case .tuesday:
            label = "Вт"
        case .wednesday:
            label = "Ср"
        case .thursday:
            label = "Чт"
        case .friday:
            label = "Пт"
        case .saturday:
            label = "Сб"
        case .sunday:
            label = "Вс"
        }
        return label
    }
}
