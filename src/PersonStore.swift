import Foundation

enum PersonStoreError: Error {
    case separatorError(line: String)
    case dateParseError(line: String)
    case CSVEmpty
    case CSVUpdateError(error: String)
    case CSVWriteError(error: String)
}

extension PersonStoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .separatorError(let line):
            return "Invalid CSV line: '\(line)'"
        case .dateParseError(let line):
            return "Unable to parse date from line: '\(line)'."
        case .CSVEmpty:
            return "CSV file is empty."
        case .CSVUpdateError(let error):
            return "Error updating CSV: \(error)"
        case .CSVWriteError(let error):
            return "Error writing to CSV: \(error)"
        }
    }
}

enum DateFormatStyle {
    case european  // DD/MM/YYYY
    case american  // MM/DD/YYYY

    func makeFormatter(separator: String = "/") -> DateFormatter {
        let formatter = DateFormatter()
        switch self {
        case .european:
            formatter.dateFormat = "d\(separator)M\(separator)yyyy"
        case .american:
            formatter.dateFormat = "M\(separator)d\(separator)yyyy"
        }
        return formatter
    }
}

extension String {
    func trim() -> String {
        self.trimmingCharacters(in: .whitespaces)
    }
}

struct PersonStore {
    let dateFormatStyle: DateFormatStyle
    let dateSeparator: String  // This separator is used in the birthday.csv file when adding a person.

    init(dateFormatStyle: DateFormatStyle, dateSeparator: String = "/") {
        self.dateFormatStyle = dateFormatStyle
        self.dateSeparator = dateSeparator
    }

    func loadPeopleFromCSV() throws -> [Person] {
        let lines = loadRawCSVLines()
        var people: [Person] = []

        let dataLines =
            (lines.first == "name,date") ? lines.dropFirst() : lines[...]

        for line in dataLines {
            let parts = line.split(separator: ",")
            guard parts.count == 2 else {
                throw PersonStoreError.separatorError(line: line)
            }

            let name = String(parts[0]).trim()
            let dateString = String(parts[1]).trim()

            guard let birthDate = parseDate(from: dateString) else {
                throw PersonStoreError.dateParseError(line: line)
            }

            people.append(Person(name: name, birthDate: birthDate))
        }

        return people
    }
    private func loadRawCSVLines() -> [String] {
        let path = csvFileURL()
        let contents = try? String(contentsOfFile: path.path, encoding: .utf8)
        return contents!.split(separator: "\n").map { String($0) }
    }

    func parseDate(from string: String) -> Date? {
        // Allow separators: / . -
        let possibleSeparators: CharacterSet = CharacterSet(charactersIn: "/.-")

        // Find which separator is present
        guard
            let separator = string.first(where: {
                possibleSeparators.contains($0.unicodeScalars.first!)
            })
        else {
            return nil  // No separator found
        }

        let parts = string.split(separator: separator).map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        guard parts.count == 3 else { return nil }

        let dayIndex: Int
        let monthIndex: Int
        let yearIndex: Int = 2

        switch dateFormatStyle {
        case .european:
            dayIndex = 0
            monthIndex = 1
        case .american:
            monthIndex = 0
            dayIndex = 1
        }

        guard
            let day = Int(parts[dayIndex]),
            let month = Int(parts[monthIndex]),
            let year = Int(parts[yearIndex])
        else {
            return nil
        }

        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)
    }

    func csvFileURL() -> URL {
        let directory = FileManager.default.currentDirectoryPath
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(
            "birthdays.csv"
        )
        createCSVFile(fileURL: fileURL)
        return fileURL
    }

    private func createCSVFile(fileURL: URL) {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let header = "name,date\n"
            do {
                try header.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Could not create CSV file: \(error)")
                return
            }
        }
    }

    func addPerson(_ people: [Person]) throws {
        let fileURL = csvFileURL()
        let formatter = dateFormatStyle.makeFormatter(
            separator: self.dateSeparator
        )

        do {
            let handle = try FileHandle(forWritingTo: fileURL)
            handle.seekToEndOfFile()
            for person in people {
                let line =
                    "\(person.name),\(formatter.string(from: person.birthDate))\n"
                if let data = line.data(using: .utf8) {
                    handle.write(data)
                }
            }
            handle.closeFile()
        } catch {
            throw PersonStoreError.CSVWriteError(error: "\(error)")
        }
    }

    func deletePerson(_ person: Person) throws {
        let fileURL = csvFileURL()
        let allPeople = try! loadPeopleFromCSV()
        let remaining = allPeople.filter {
            !($0.name == person.name
                && Calendar.current.isDate(
                    $0.birthDate,
                    inSameDayAs: person.birthDate
                ))
        }

        let formatter = dateFormatStyle.makeFormatter(
            separator: self.dateSeparator
        )

        var newContent = "name,date\n"
        for person in remaining {
            newContent +=
                "\(person.name),\(formatter.string(from: person.birthDate))\n"
        }

        do {
            try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw PersonStoreError.CSVUpdateError(error: "\(error)")

        }
    }
}
