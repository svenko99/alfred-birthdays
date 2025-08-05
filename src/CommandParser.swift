import Foundation

enum Command {
    case list(query: String?)
    case add(name: String, dateString: String)
    case delete(name: String, dateString: String)
}

struct CommandParser {
    static func parse(arguments: [String]) -> Command? {
        guard arguments.count >= 2 else {
            return .list(query: nil)  // default command if nothing provided
        }

        let command = arguments[1].lowercased()

        switch command {
        case "list":
            let query = arguments.count > 2 ? arguments[2...].joined(separator: " ") : nil
            return .list(query: query)

        case "add", "delete":
            guard arguments.count >= 3 else { return nil }
            let joined = arguments[2...].joined(separator: " ")
            let components = joined.split(separator: ",", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            guard components.count == 2 else { return nil }
            if command == "add" {
                return .add(name: components[0], dateString: components[1])
            } else {
                return .delete(name: components[0], dateString: components[1])
            }

        default:
            return nil
        }
    }
}
