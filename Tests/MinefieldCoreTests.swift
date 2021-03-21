//
//  MinefieldCoreTests.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 15/03/2021.
//

import XCTest
import TCAminesweeperCommon
import ComposableArchitecture
import TileCore
@testable import MinefieldCore

class MinefieldCoreTests: XCTestCase {
    var resultMock: MinefieldState.Result?
    
    func testTileTapped() {
        self.resultMock = .lost
        
        store.assert(
            .send(.tile(1, .tapped)),
            .receive(.resultChanged(.lost)) {
                $0.result = .lost
            }
        )
    }
    
    func testTileLongPressed() {
        store.assert(
            .send(.tile(1, .longPressed)),
            .receive(.toogleMark(1)) {
                $0.grid.content[1].isMarked = true
                $0.gridInfo.flagged = [1]
            },
            .send(.tile(1, .longPressed)),
            .receive(.toogleMark(1)) {
                $0.grid.content[1].isMarked = false
                $0.gridInfo.flagged = []
            }
        )
    }
    
    lazy var store = TestStore(
        initialState: .oneMine,
        reducer: minefieldReducer,
        environment: .mock(tileTappedHandler: {_,_ in
            if let result = self.resultMock {
                return Effect(value: result)
            } else {
                return .none
            }
        })
    )
}
