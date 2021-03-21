//
//  AppCoreTests.swift
//  AppCoreTests
//
//  Created by Igor Bidiniuc on 17/03/2021.
//

import XCTest
import ComposableArchitecture
import SettingsService
import SettingsCore
import NewGameCore
import GameCore
import TCAminesweeperCommon
import HighScoreService
import HighScoresCore
@testable import AppCore

class AppCoreTests: XCTestCase {

    func testFlow_Settings() {
        let userSettingsMock = UserSettings(otherThanCustom: .easy)
        let settingsMock = SettingsState(userSettings: userSettingsMock)
        let settingsServiceMock = SettingsService.mock(userSettings: { Effect(value: userSettingsMock) })
        let store = TestStore(
            initialState: AppState(newGame: NewGameState(game: GameState(difficulty: .easy, minefieldState: .oneMine))),
            reducer: appReducer,
            environment: .mock(
                newGame: .mock(
                    minefieldGenerator: { _ in .none },
                    settingsService: settingsServiceMock
                ),
                settings: .mock(settingsService: settingsServiceMock)
            )
        )
        
        let openSettings: TestStore<AppState, AppState, AppAction, AppAction, AppEnvironment>.Step =
            .sequence([
                .send(.settingsButtonTapped),
                .receive(.showSettings(settingsMock)) {
                    $0.settings = settingsMock
                    $0.sheet = .settings
                },
                .receive(.newGameAction(.gameAction(.onDisappear)))
            ])
        
        store.assert(
            openSettings,
            .send(.settingsAction(.cancelButtonTapped)) {
                $0.sheet = nil
            },
            
            openSettings,
            .send(.dismiss) {
                $0.settings = nil
                $0.sheet = nil
            },
            .receive(.newGameAction(.gameAction(.onAppear)))
        )
    }
    
    func testFlow_HighScore() {
        let scoresMock = [UserHighScore(id: .init(), score: 0, userName: nil, date: Date())]
        let highScoresMock = HighScoreState(difficulty: .easy, scores: scoresMock)
        let store = TestStore(
            initialState: AppState(newGame: NewGameState(game: GameState(difficulty: .easy, minefieldState: .oneMine))),
            reducer: appReducer,
            environment: .mock(
                highScores: .mock(highScoreService: HighScoreService.mock(scores: { difficulty in
                    XCTAssertEqual(difficulty, .easy)
                    return Effect(value: scoresMock)
                }))
            )
        )
        
        let openHighScores: TestStore<AppState, AppState, AppAction, AppAction, AppEnvironment>.Step =
            .sequence([
                .send(.highScoresButtonTapped),
                .receive(.showHighScores(highScoresMock)) {
                    $0.highScores = highScoresMock
                    $0.sheet = .highScores
                },
                .receive(.newGameAction(.gameAction(.onDisappear)))
            ])
        
        store.assert(
            openHighScores,
            .send(.highScoresAction(.cancelButtonTapped)) {
                $0.sheet = nil
            },
            
            openHighScores,
            .send(.dismiss) {
                $0.highScores = nil
                $0.sheet = nil
            },
            .receive(.newGameAction(.gameAction(.onAppear)))
        )
    }
    
}
