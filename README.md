
# 🎂 Alfred Birthdays Workflow

A simple [Alfred](https://www.alfredapp.com/) workflow to manage birthdays stored in a CSV file.

<img src="assets/picture1.png" alt="demo picture 1" width="80%" height="auto">


<img src="assets/picture2.png" alt="demo picture 1" width="80%" height="auto">

## 🔧 Main Features

- **`bday`** – search for birthdays by name
	- If no search query is entered, all birthdays are shown.
 	- **The output format is: Name, Days until next birthday, Age on next birthday.**
	- Press `Shift + Enter` on an entry to delete it.
- **`add bday John Doe,9/3/2003`** – add a new person
- **`edit bday`** – open `birthdays.csv` in text editor for bulk editing
- **`build bday`** – build workflow program (requires [Xcode Command Line Tools](https://www.geeksforgeeks.org/techtips/how-to-install-xcode-command-line-tools/))

## 📂 File format

Birthdays are stored in a file named `birthdays.csv`, located in the workflow's directory. Name and date are **comma-separated**. The date format is flexible – it supports different separators: `/`, `-`, or `.`. Each line must follow one of this formats:

```csv
name,date
John Doe,9/3/2003
John Doe,9-3-1990
John Doe,9.3.1990
```


<details>
<summary>This is an example of valid file content</summary>
</br>
<ul style="list-style-type: none">
<li>
<code style="display: block; white-space: pre-wrap">name,date
Alice Smith,1/1/2000
Bob Johnson,31/12/1995
Charlie Brown,15-8-1988
Diana Prince, 4.7.1992
Evan, 25/12/2001
George,5/11/1999
</code>
</li>
</ul>

</details>

## 📦 Installation

Install [⤓ Alfred Birthdays Workflow](https://github.com/svenko99/alfred-birthdays/releases/latest/download/Birthdays.alfredworkflow) from the repository.

The workflow includes a precompiled `alfred-birthday` binary. If macOS blocks it, run `sudo xattr -rd com.apple.quarantine ./alfred-birthday` inside workflow's directory.

Alternatively, if you have [Xcode Command Line Tools](https://www.geeksforgeeks.org/techtips/how-to-install-xcode-command-line-tools/), you can build the binary yourself via Alfred: `build bday`. This will run `swiftc src/*.swift -o ./alfred-birthday`

## 💭 Why Swift?

The workflow could have been done in Python much more easily. I made the workflow in Swift because I wanted to learn the language. I've grown quite fond of Swift. It has very good support for lambda functions (closures), interesting things like `extensions` and more. Swift also speeds up the execution, which is not really crucial for this workflow. ~The only thing that bothers me is that I would have to pay [$99 for a developer account](https://developer.apple.com/help/account/membership/program-enrollment/) to be able to sign the binary file.~ **I actually paid for it, so now the binary file is signed and notorized.**

## ✔️ To-do

- [ ] Remove filtering birthdays, because Alfred handles that. Adjust `CommandParser.swift` and `Handlers.swift`. Exclude `$1` from Script Filter of `bday`
- [X] Add `:` to keyword for building binary (`build bday`)
