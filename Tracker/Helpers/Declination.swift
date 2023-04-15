import Foundation

func declineDay(_ day: Int) -> String {
    var result = "\(day) день"

    let mod10 = day % 10
    let mod100 = day % 100

    if mod10 == 1 && mod100 != 11 {
        result = "\(day) день"
    } else if mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20) {
        result = "\(day) дня"
    } else {
        result = "\(day) дней"
    }

    return result
}
