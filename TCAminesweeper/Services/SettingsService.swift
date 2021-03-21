//
//  SettingsService.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import ComposableArchitecture
import TCAminesweeperCommon

public struct SettingsService {
    public let userSettings: () -> Effect<UserSettings, Never>
    public let saveUserSettings: (UserSettings) -> Effect<Never, Never>
    
    public init(
        userSettings: @escaping () -> Effect<UserSettings, Never>,
        saveUserSettings: @escaping (UserSettings) -> Effect<Never, Never>
    ) {
        self.userSettings = userSettings
        self.saveUserSettings = saveUserSettings
    }
}

#if DEBUG

public extension SettingsService {
    static func mock(
        userSettings: @escaping () -> Effect<UserSettings, Never> = { fatalError() },
        saveUserSettings: @escaping (UserSettings) -> Effect<Never, Never> = {_ in fatalError()}
    ) -> Self {
        Self(
            userSettings: userSettings,
            saveUserSettings: saveUserSettings
        )
    }
    
    static let preview = Self.mock(
        userSettings: { .none },
        saveUserSettings: {_ in .none}
    )
}

#endif
