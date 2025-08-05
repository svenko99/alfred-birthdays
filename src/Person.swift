import Foundation

struct Person {
    let name: String
    let birthDate: Date

    var nextBirthdayDate: Date {
        let calendar = Calendar.current
        let today = Calendar.current.startOfDay(for: Date())

        var components = DateComponents(
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: self.birthDate),
            day: calendar.component(.day, from: self.birthDate)
        )

        guard let birthdayThisYear = calendar.date(from: components) else {
            return today  // fallback
        }

        if birthdayThisYear < today {
            components.year! += 1
            return calendar.date(from: components)!
        } else {
            return birthdayThisYear
        }
    }

    var daysUntilNextBirthday: Int {
        let diff = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: self.nextBirthdayDate)
        )

        return diff.day ?? -1
    }

    var upcompingAge: Int {
        let diff = Calendar.current.dateComponents(
            [.year],
            from: self.birthDate,
            to: self.nextBirthdayDate,
        )
        return diff.year ?? -1
    }

    func formattedBirthDate(
        dateFormatStyle: DateFormatStyle,
        dateSeparator: String = "/"
    ) -> String {
        let formatter = dateFormatStyle.makeFormatter(separator: dateSeparator)
        return formatter.string(from: self.birthDate)
    }

}
