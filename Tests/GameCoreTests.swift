//
//  GameCoreTests.swift
//  GameCoreTests
//
//  Created by Igor Bidiniuc on 16/03/2021.
//

import XCTest
import TCAminesweeperCommon
import ComposableArchitecture
import MinefieldCore
@testable import GameCore

class GameCoreTests: XCTestCase {
    
    let timerScheduler = DispatchQueue.testScheduler
    let mainQueue = DispatchQueue.testScheduler
    var selectionFeedbackCalled = false
    var notificationFeedbackType: GameEnvironment.NotificationFeedbackType?
    
    var resultMock: MinefieldState.Result?
    
    func testFlow_Win() {
        store.assert(
            .sequence(startGame()),
            .sequence(scoreIncrement()),
            .sequence(gameOver(result: .win, gameState: .over(score: 1)))
        )
    }
    
    func testFlow_Lost() {
        store.assert(
            .sequence(startGame()),
            .sequence(scoreIncrement()),
            .sequence(gameOver(result: .lost, gameState: .over(score: nil)))
        )
    }

    func testFlow_RestartGame() {
        store.assert(
            .sequence(startGame()),
            .sequence(gameOver(result: .lost, gameState: .over(score: nil))),
            .send(.startNewGame(.twoMines)) {
                $0.minefieldState = .twoMines
            },
            .receive(.gameStateChanged(.new)) {
                $0.gameState = .new
                $0.headerState = HeaderState(
                    leadingText: "002",
                    centerText: "🙂",
                    trailingText: "000"
                )
            }
        )
    }
    
    func testFlow_MarkTile() {
        store.assert(
            .send(.minefieldAction(.tile(0, .longPressed))),
            .receive(.minefieldAction(.toogleMark(0))) {
                $0.minefieldState.grid.content[0].isMarked = true
                $0.minefieldState.gridInfo.flagged = [0]
                XCTAssertTrue(self.selectionFeedbackCalled)
            },
            .receive(.gameStateChanged(.inProgress(0))) {
                $0.gameState = .inProgress(0)
            },
            .receive(.updateRemainedMines) {
                $0.headerState.leadingText = "000"
            },
            .receive(.updateRemainedMines),
            .receive(.gameStarted),
            .sequence(scoreIncrement()),
            .sequence(gameOver(result: .win, gameState: .over(score: 1)))
        )
    }
    
    func test_onDisapper() {
        store.assert(
            .sequence(startGame()),
            .send(.onDisappear),
            .do {
                self.timerScheduler.advance(by: 2)
                self.mainQueue.advance()
            },
            .send(.onAppear),
            .receive(.gameStarted),
            .do {
                self.timerScheduler.advance(by: 1)
                self.mainQueue.advance()
            },
            .receive(.timerUpdated) {
                $0.gameState = .inProgress(1)
                $0.headerState.trailingText = "001"
            },
            .sequence(gameOver(result: .win, gameState: .over(score: 1)))
        )
    }
    
    // MARK: - Steps
    
    private func scoreIncrement() -> [TestStore<GameState, GameState, GameAction, GameAction, GameEnvironment>.Step] {
        [
            .do {
                self.timerScheduler.advance(by: 1)
                self.mainQueue.advance()
            },
            .receive(.timerUpdated) {
                $0.gameState = .inProgress(1)
                $0.headerState.trailingText = "001"
            },
        ]
    }
    
    private func startGame(leadingText: String = "001") -> [TestStore<GameState, GameState, GameAction, GameAction, GameEnvironment>.Step] {
        [
            .send(.minefieldAction(.tile(0, .tapped))),
            .receive(.gameStateChanged(.inProgress(0))) {
                $0.gameState = .inProgress(0)
            },
            .receive(.updateRemainedMines) {
                $0.headerState.leadingText = leadingText
            },
            .receive(.gameStarted)
        ]
    }
    
    private func gameOver(
        result: MinefieldState.Result,
        gameState: GameState.State
    ) -> [TestStore<GameState, GameState, GameAction, GameAction, GameEnvironment>.Step] {
        [
            .do {
                self.resultMock = result
            },
            .send(.minefieldAction(.tile(0, .tapped))),
            .receive(.minefieldAction(.resultChanged(result))) {
                $0.minefieldState.result = result
            },
            .receive(.gameStateChanged(gameState)) {
                $0.gameState = gameState
                $0.headerState.centerText =  result.isWin ? "😎" : "🤯"
                XCTAssertEqual(self.notificationFeedbackType, result.isWin ? .success : .error)
            },
            .do {
                self.timerScheduler.advance()
                self.mainQueue.advance()
            }
        ]
    }
    
    lazy var store = TestStore(
        initialState: GameState(
            difficulty: .easy,
            minefieldState: .oneMine
        ),
        reducer: gameReducer,
        environment: .mock(
            minefieldEnvironment: .mock(tileTappedHandler: {_, _ in
                guard let result = self.resultMock else { return .none }
                return Effect(value: result)
            }),
            timerScheduler: .init(timerScheduler),
            mainQueue: .init(mainQueue),
            selectionFeedback: { [weak self] in self?.selectionFeedbackCalled = true; return .none },
            notificationFeedback: { [weak self] notificationType in self?.notificationFeedbackType = notificationType; return.none }
        )
    )
}
