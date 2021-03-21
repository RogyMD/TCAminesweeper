//
//  NewGameCoreTests.swift
//  NewGameCoreTests
//
//  Created by Igor Bidiniuc on 15/03/2021.
//

import XCTest
import ComposableArchitecture
import GameCore
import TCAminesweeperCommon
import MinefieldCore
import NewGameCore
import TileCore
import SettingsService

class NewGameCoreTests: XCTestCase {
    
    let timerScheduler = DispatchQueue.testScheduler
    let mainQueue = DispatchQueue.testScheduler
    
    var minefieldGeneratorMock: MinefieldState = .oneMine
    var uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    var now = Date(timeIntervalSince1970: 0)
    var resultMock: MinefieldState.Result?
    var showsHighScoreAlert = false
    var savedScores: [UserHighScore] = []
    
    func testFlow_Win_ShowsHighScoreAlertTrue() {
        showsHighScoreAlert = true
        
        store.assert(
            .sequence(startNewGame()),
            .sequence(gameOver(result: .win, gameState: .over(score: 0))),
            .receive(.showAlert) {
                $0.showsHighScoreAlert = true
            },
            .send(.alertActionButtonTapped("Igor")) { _ in
                self.assertSavedScores([UserHighScore(id: self.uuid, score: 0, userName: "Igor", date: self.now)])
            },
            .send(.dismissAlert) {
                $0.showsHighScoreAlert = false
            }
        )
    }
    
    func testFlow_Win_ShowsHighScoreAlertFalse() {
        showsHighScoreAlert = false
        
        store.assert(
            .sequence(startNewGame()),
            .sequence(gameOver(result: .win, gameState: .over(score: 0)))
        )
    }
    
    func testFlow_Lost() {
        store.assert(
            .sequence(startNewGame()),
            .sequence(gameOver(result: .lost, gameState: .over(score: nil)))
        )
    }
    
    func testRestartGame() {
        let newGame = GameState(difficulty: .easy, minefieldState: .twoMines)
        
        store.assert(
            .sequence(startNewGame()),
            .do {
                self.minefieldGeneratorMock = newGame.minefieldState
            },
            .send(.gameAction(.headerAction(.buttonTapped))),
            .receive(.startNewGame),
            .receive(.newGame(newGame)) {
                $0.game = newGame
            },
            .receive(.gameAction(.startNewGame(newGame.minefieldState))),
            .receive(.gameAction(.gameStateChanged(.new))),
            .send(.gameAction(.minefieldAction(.tile(0, .tapped)))),
            .receive(.gameAction(.gameStateChanged(.inProgress(0)))) {
                $0.game?.gameState = .inProgress(0)
            },
            .receive(.gameAction(.updateRemainedMines)) {
                $0.game?.headerState.leadingText = "002"
            },
            .receive(.gameAction(.gameStarted)),
            .sequence(gameOver(result: .lost, gameState: .over(score: nil)))
        )
    }
    
    private func startNewGame(
        difficulty: Difficulty = .easy,
        minefield: MinefieldState = .oneMine
    ) -> [TestStore<NewGameState, NewGameState, NewGameAction, NewGameAction, NewGameEnvironment>.Step] {
        let game = GameState(difficulty: difficulty, minefieldState: minefield)
        
        return [
            .send(.startNewGame),
            .receive(.newGame(game)) {
                $0.game = game
            },
            .receive(.gameAction(.startNewGame(game.minefieldState))),
            .receive(.gameAction(.gameStateChanged(.new))),
            .send(.gameAction(.minefieldAction(.tile(0, .tapped)))),
            .receive(.gameAction(.gameStateChanged(.inProgress(0)))) {
                $0.game?.gameState = .inProgress(0)
            },
            .receive(.gameAction(.updateRemainedMines)) {
                $0.game?.headerState.leadingText = String(format: "%03d", minefield.gridInfo.mines.count)
            },
            .receive(.gameAction(.gameStarted))
        ]
    }
    
    private func gameOver(
        result: MinefieldState.Result,
        gameState: GameState.State
    ) -> [TestStore<NewGameState, NewGameState, NewGameAction, NewGameAction, NewGameEnvironment>.Step] {
        return [
            .do {
                self.resultMock = result
            },
            .send(.gameAction(.minefieldAction(.tile(0, .tapped)))),
            .receive(.gameAction(.minefieldAction(.resultChanged(result)))) {
                $0.game?.minefieldState.result = result
                
                // advance timers to finish the game
                self.timerScheduler.advance()
                self.mainQueue.advance()
            },
            .receive(.gameAction(.gameStateChanged(gameState))) {
                $0.game?.gameState = gameState
                $0.game?.headerState.centerText =  result.isWin ? "😎" : "🤯"
            }
        ]
    }
    
    private func assertSavedScores(_ scores: [UserHighScore]) {
        XCTAssertEqual(self.savedScores, scores)
        self.savedScores.removeAll()
    }
    
    lazy var store = TestStore(
        initialState: NewGameState(),
        reducer: newGameReducer,
        environment: .mock(
            minefieldGenerator: { _ in
                Effect(value: self.minefieldGeneratorMock)
            },
            uuid: { self.uuid },
            now: { self.now },
            game: .mock(
                minefieldEnvironment: .mock(tileTappedHandler: {_, _ in
                    guard let result = self.resultMock else { return .none }
                    return Effect(value: result)
                }),
                timerScheduler: .init(self.timerScheduler),
                mainQueue: .init(self.mainQueue)
            ),
            settingsService: .mock(
                userSettings: { Effect(value: UserSettings(otherThanCustom: .easy)) }
            ),
            highScoreService: .mock(
                isScoreInTop10: {_, _ in Effect(value: self.showsHighScoreAlert) },
                saveScore: { userScore, _ in
                    self.savedScores.append(userScore)
                    return .none
                }
            )
        ))
}
