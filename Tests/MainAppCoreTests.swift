//
//  MainAppCoreTests.swift
//  MainAppCoreTests
//
//  Created by Igor Bidiniuc on 27/03/2021.
//

import XCTest
import ComposableArchitecture
import AppCore
import SettingsCore
import NewGameCore
import GameCore
@testable import MainAppCore

class MainAppCoreTests: XCTestCase {
    
    func test_newGameCommand_settingsNotNil() {
        let store = TestStore(
            initialState: MainAppState(
                app: AppState(
                    newGame: NewGameState(game: GameState(difficulty: .easy, minefieldState: .oneMine)),
                    sheet: .settings,
                    settings: SettingsState(userSettings: .default))
            ),
            reducer: mainAppReducer,
            environment: .mock(
                app: .mock(
                    newGame: .mock(settingsService: .mock(userSettings: { .none })),
                    settings: .mock(),
                    highScores: .mock())
            )
        )
        
        store.assert(
            .send(.newGameCommand),
            .receive(.appAction(.settingsAction(.newGameButtonTapped))),
            .receive(.appAction(.newGameAction(.startNewGame))),
            .receive(.appAction(.dismiss)) {
                $0.app.sheet = nil
                $0.app.settings = nil
            },
            .receive(.appAction(.newGameAction(.gameAction(.onAppear))))
        )
    }
    
    func test_newGameCommand_settingsNil() {
        let store = TestStore(
            initialState: MainAppState(
                app: AppState(newGame: NewGameState(game: GameState(difficulty: .easy, minefieldState: .oneMine)))
            ),
            reducer: mainAppReducer,
            environment: .mock(
                app: .mock(
                    newGame: .mock(settingsService: .mock(userSettings: { .none })),
                    settings: .mock(),
                    highScores: .mock())
            )
        )
        
        store.assert(
            .send(.newGameCommand),
            .receive(.appAction(.newGameAction(.startNewGame)))
        )
    }
    
    func test_settingsCommand() {
        let store = TestStore(
            initialState: MainAppState(
                app: AppState(newGame: NewGameState(game: GameState(difficulty: .easy, minefieldState: .oneMine)))
            ),
            reducer: mainAppReducer,
            environment: .mock(
                app: .mock(
                    newGame: .mock(),
                    settings: .mock(settingsService: .mock(userSettings: { .none })),
                    highScores: .mock())
            )
        )
        
        store.assert(
            .send(.settingsCommand),
            .receive(.appAction(.settingsButtonTapped))
        )
    }


}
