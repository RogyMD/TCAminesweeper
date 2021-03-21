//
//  LiveMinefieldEnvironmentTests.swift
//  TCAminesweeperTests
//
//  Created by Igor Bidiniuc on 20/03/2021.
//

import XCTest
import MinefieldCore
import TCAminesweeperCommon
import SnapshotTesting
import NewGameCore
@testable import TCAminesweeper

class LiveMinefieldEnvironmentTests: XCTestCase {

    var state: MinefieldState!
    var snapshotState: MinefieldState { state }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
//        isRecording = true
        
        let grid = try XCTUnwrap(Grid.fromDescription(
"""
___________
|11        |
|💣1        |
|11111  111|
| 12💣1112💣1|
| 1💣211💣211|
|12233321  |
|💣22💣💣💣1   |
|2💣22321   |
|111       |
|          |
___________
"""
        ))
        let mines = Set(grid.content.indices.filter { grid.content[$0].tile == .mine })
        state = MinefieldState(grid: grid, gridInfo: .init(mines: mines))
    }
    
    override func tearDownWithError() throws {
        state = nil
        
        try super.tearDownWithError()
    }
    
    func test_tileTappedHandler_tileMine() throws {
        let result = MinefieldEnvironment.tileTappedHandler(index: 10, state: &state)
        
        XCTAssertEqual(result, .lost)
        assertSnapshot(matching: snapshotState, as: .description)
    }
    
    func test_tileTappedHandler_tileEmpty() throws {
        let result = MinefieldEnvironment.tileTappedHandler(index: 5, state: &state)
        
        XCTAssertNil(result)
        assertSnapshot(matching: snapshotState, as: .description)
    }
    
    func test_tileTappedHandler_tileNumber() throws {
        let result = MinefieldEnvironment.tileTappedHandler(index: 0, state: &state)
        
        XCTAssertNil(result)
        assertSnapshot(matching: snapshotState, as: .description)
    }
    
    func test_tileTappedHandler_tileNumber_Win() throws {
        state.grid.content.indices.forEach { index in
            guard !state.gridInfo.mines.contains(index) else {
                return
            }
            state.reveal(index)
        }
        let result = MinefieldEnvironment.tileTappedHandler(index: 0, state: &state)
        
        XCTAssertEqual(result, .win)
        assertSnapshot(matching: snapshotState, as: .description)
    }
    
    func test_prepareStateForLoss() throws {
        MinefieldEnvironment.prepareStateForLoss(state: &state, mineIndex: 10)
        
        assertSnapshot(matching: snapshotState, as: .description)
    }

    func test_prepareStateForWin() throws {
        state.setMarked(true, for: 10)
        
        MinefieldEnvironment.prepareStateForWin(state: &state)
        
        assertSnapshot(matching: snapshotState, as: .description)
    }
    
    func test_revealTilesBesideTile() throws {
        MinefieldEnvironment.revealTilesBesideTile(at: 4, state: &state)
        
        assertSnapshot(matching: snapshotState, as: .description)
    }
    
}


