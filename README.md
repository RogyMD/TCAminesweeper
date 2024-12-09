![App Icon](Assets/README/app_icon.png)
[<img src="https://i0.wp.com/rogy.app/wp-content/uploads/2024/12/downlaod-from-app-store.png" width="150">]([https://rogy.app/minesweeper](https://apps.apple.com/app/minesweeper-v1-0/id6738613938)


## Minesweeper

This project is a copy of the Windows game Minesweeper.

## About

Minesweeper is an iOS & Mac Catalyst application built entirely in Swift. The logic is build in the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and the UI is built in SwiftUI.

The project shows following use cases:

* Highly modularized: every feature is isolated into its own module with minimal dependencies between them, allowing us to compile and run features in isolation without building the entire application.
* Fully controlled side effects. Every feature is provided with all the dependencies it needs to do its work, which makes testing very easy.
* The core logic of the application is put into modules named like *Core, and they are kept separate from modules containing UI, which is what allows us to share code across multiple platforms (SwiftUI and UIKit), but could also allow us to share code across iOS, macOS, watchOS and tvOS apps.
* Comprehensive test suite for every feature, including integration tests of many features working in unison, and end-to-end testing of side effects.

## Screenshots

| Game | High Scores | Settings |
|---|---|---|
| <img src="Assets/README/game.png" width="300"> | <img src="Assets/README/high_scores.png" width="300"> | <img src="Assets/README/settings.png" width="300"> |

| Mac Catalyst |
|---|
|![macOS](Assets/README/mac_os.png)|

## License

The source code in this repository may be run and altered for education purposes only and not for commercial purposes. For more information [see LICENSE](https://raw.githubusercontent.com/RogyMD/TCAminesweeper/master/LICENSE).
