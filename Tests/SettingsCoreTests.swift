//
//  SettingsCoreTests.swift
//  SettingsCoreTests
//
//  Created by Igor Bidiniuc on 20/03/2021.
//

import XCTest
import ComposableArchitecture
import TCAminesweeperCommon
import SettingsService
@testable import SettingsCore

class SettingsCoreTests: XCTestCase {

    func test_binding_difficulty() {
        let store = TestStore(
            initialState: SettingsState(userSettings: UserSettings(otherThanCustom: .easy)),
            reducer: settingsReducer,
            environment: .mock(settingsService: .mock(saveUserSettings: { _ in .none }))
        )
        
        store.assert(
            .send(.binding(.set(\.difficulty, .normal))) {
                $0.difficulty = .normal
                $0.minefieldAttributes = Difficulty.normal.minefieldAttributes!
            },
            .receive(.saveSettings),
            .send(.binding(.set(\.difficulty, .custom))) {
                $0.difficulty = .custom
            },
            .receive(.saveSettings)
        )
    }
    
    func test_saveSettings() {
        var savedUserSettings: UserSettings?
        let store = TestStore(
            initialState: SettingsState(userSettings: UserSettings(otherThanCustom: .easy)),
            reducer: settingsReducer,
            environment: .mock(settingsService: .mock(saveUserSettings: {
                savedUserSettings = $0
                return .none
            }))
        )
        
        store.assert(
            .send(.saveSettings) {
                XCTAssertEqual($0.userSettings, savedUserSettings)
            }
        )
    }
    
    func test_binding_minefieldAttributes() {
        let userSettings = UserSettings(minefieldAttributes: MinefieldAttributes(rows: 100, columns: 100, mines: 100*100))
        let store = TestStore(
            initialState: SettingsState(userSettings: userSettings),
            reducer: settingsReducer,
            environment: .mock(settingsService: .mock(saveUserSettings: { _ in .none }))
        )
        
        store.assert(
            .send(.binding(.set(\SettingsState.minefieldAttributes.rows, UInt(100)))) {
                $0.minefieldAttributes.normalize()
            },
            .receive(.saveSettings)
        )
    }

}
