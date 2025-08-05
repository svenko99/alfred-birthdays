import Foundation

let env = ProcessInfo.processInfo.environment

let dateFormat: DateFormatStyle = {
    if env["date_format"]?.lowercased() == "american" {
        return .american
    } else {
        return .european
    }
}()

let separator: String = env["date_separator"] ?? "/"
let store = PersonStore(dateFormatStyle: dateFormat, dateSeparator: separator)

guard let command = CommandParser.parse(arguments: CommandLine.arguments) else {
    print(AlfredItem(title: "Invalid command"))
    exit(1)
}

switch command {
case .list(let query):
    handleList(
        store: store,
        format: dateFormat,
        separator: separator,
        query: query
    )
case .add(let name, let dateString):
    handleAdd(
        name: name,
        dateString: dateString,
        store: store,
        format: dateFormat,
        separator: separator
    )
case .delete(let name, let dateString):
    handleDelete(
        name: name,
        dateString: dateString,
        store: store,
        format: dateFormat,
        separator: separator
    )
}
