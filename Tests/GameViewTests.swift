//
//  GameViewTests.swift
//  GameViewTests
//
//  Created by Igor Bidiniuc on 16/03/2021.
//

import XCTest
import ComposableArchitecture
import GameCore
import MinefieldCore
@testable import GameView

class GameViewTests: XCTestCase {
    
    let timerScheduler = DispatchQueue.testScheduler
    let mainQueue = DispatchQueue.testScheduler
    
    var resultMock: MinefieldState.Result?
    
    func testFlow_MarkTile_Win() {
        store.assert(
            .send(.minefieldAction(.tile(0, .longPressed))),
            .receive(.minefieldAction(.toogleMark(0))),
            .receive(.gameStateChanged(.inProgress(0))),
            .receive(.updateRemainedMines) {
                $0.navigationBarLeadingText = "000"
            },
            .receive(.updateRemainedMines),
            .receive(.gameStarted),
            .sequence(gameOver(result: .win, gameState: .over(score: 0)))
        )
    }
    
    func testFlow_UpdateScore_Lost() {
        store.assert(
            .send(.minefieldAction(.tile(0, .tapped))),
            .receive(.gameStateChanged(.inProgress(0))),
            .receive(.updateRemainedMines) {
                $0.navigationBarTrailingText = "000"
            },
            .receive(.gameStarted),
            .do {
                self.timerScheduler.advance(by: 2)
                self.mainQueue.advance(by: 2)
            },
            .receive(.timerUpdated) {
                $0.navigationBarTrailingText = "001"
            },
            .receive(.timerUpdated) {
                $0.navigationBarTrailingText = "002"
            },
            .sequence(gameOver(result: .lost, gameState: .over(score: nil)))
        )
    }

    private func gameOver(
        result: MinefieldState.Result,
        gameState: GameState.State
    ) -> [TestStore<GameState, GameView.ViewState, GameAction, GameAction, GameEnvironment>.Step] {
        [
            .do {
                self.resultMock = result
            },
            .send(.minefieldAction(.tile(0, .tapped))),
            .receive(.minefieldAction(.resultChanged(result))),
            .receive(.gameStateChanged(gameState)) {
                $0.navigationBarCenterText =  result.isWin ? "😎" : "🤯"
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
            mainQueue: .init(mainQueue)
        ))
        .scope(state: { $0.view })
}
