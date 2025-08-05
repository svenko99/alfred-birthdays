import Foundation

func handleList(
    store: PersonStore,
    format: DateFormatStyle,
    separator: String,
    query: String? = nil
) {

    do {
        let env = ProcessInfo.processInfo.environment
        let people = try store.loadPeopleFromCSV()
        if people.isEmpty {
            print(
                AlfredItem(
                    title: "No birthdays found",
                    subtitle:
                        "Add someone: add \(env["keyword"] ?? "birthdays") John Smith,9/10/1992"
                )
            )
            return
        }

        let sorted = people.sorted {
            $0.daysUntilNextBirthday < $1.daysUntilNextBirthday
        }

        let filtered = {
            if let query = query?.lowercased(), !query.isEmpty {
                return sorted.filter { $0.name.lowercased().contains(query) }
            } else {
                return sorted
            }
        }()

        let items = filtered.map {
            let isBirthdayToday = $0.daysUntilNextBirthday == 0
            let iconPath =
                isBirthdayToday ? "./images/cake.png" : "./images/calendar.png"
            return AlfredItem(
                title:
                    "\($0.name) | \($0.daysUntilNextBirthday == 0 ? "Today!" : "\($0.daysUntilNextBirthday) \($0.daysUntilNextBirthday == 1 ? "day" : "days")") | \($0.upcompingAge) years",
                subtitle: $0.formattedBirthDate(
                    dateFormatStyle: format,
                    dateSeparator: separator
                ),
                arg:
                    "\($0.name),\($0.formattedBirthDate(dateFormatStyle: format, dateSeparator: separator))",
                icon: Icon(path: iconPath)
            )
        }

        print(AlfredItems(items: items))
    } catch {
        print(
            AlfredItem(
                title: "Error reading birthdays file (CSV)",
                subtitle: error.localizedDescription
            )
        )
    }
}

func handleAdd(
    name: String,
    dateString: String,
    store: PersonStore,
    format: DateFormatStyle,
    separator: String
) {
    guard let date = store.parseDate(from: dateString) else {
        print("Error in date. Use the format e.g. 9/10/1992")
        return
    }
    let person = Person(name: name, birthDate: date)
    do {
        try store.addPerson([person])
        print(
            "\(person.name) (\(person.formattedBirthDate(dateFormatStyle: format, dateSeparator: separator))) added."
        )
    } catch {
        print("Error while adding a person.")
    }
}

func handleDelete(
    name: String,
    dateString: String,
    store: PersonStore,
    format: DateFormatStyle,
    separator: String
) {
    do {
        let people = try store.loadPeopleFromCSV()
        guard
            let personToDelete = people.first(where: {
                $0.name.lowercased() == name.lowercased()
                    && $0.formattedBirthDate(
                        dateFormatStyle: format,
                        dateSeparator: separator
                    ).trim() == dateString.trim()
            })
        else {
            print("Person \(name) not found.")
            return
        }
        try store.deletePerson(personToDelete)
        print(
            "\(personToDelete.name) (\(personToDelete.formattedBirthDate(dateFormatStyle: format, dateSeparator: separator))) is deleted."
        )
    } catch {
        print("Error occurred during deletion.")
    }
}
