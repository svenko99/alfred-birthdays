import Foundation

struct AlfredItem: Codable, CustomStringConvertible {
    let title: String
    let subtitle: String?
    let arg: String?
    let icon: Icon?

    init(
        title: String,
        subtitle: String? = nil,
        arg: String? = nil,
        icon: Icon? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.arg = arg
        self.icon = icon
    }

    func toJSON() -> String {
        AlfredItems(items: [self]).toJSON()
    }

    var description: String {
        return toJSON()
    }
}

struct Icon: Codable {
    let path: String
}

struct AlfredItems: Codable, CustomStringConvertible {
    let items: [AlfredItem]

    init(items: [AlfredItem]) {
        self.items = items
    }

    init() {
        self.items = []
    }

    func toJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)!
        } catch {
            return
                "{\"items\":[{\"title\":\"Napaka pri kodiranju JSON\",\"subtitle\":\"\(error.localizedDescription)\",\"valid\":false}]}"
        }

    }

    var description: String {
        return toJSON()
    }
}
