//
//  GridTests.swift
//  TCAminesweeperTests
//
//  Created by Igor Bidiniuc on 18/03/2021.
//

import XCTest
import TileCore
import TCAminesweeperCommon
import SnapshotTesting
@testable import TCAminesweeper

class GridTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        
//        isRecording = true
    }
    
    func test_indexesBeside_12() {
        let grid = Grid<TileState>(rows: 5, columns: 5)
        let index = 12
        let besideIndexes = grid.indexes(beside: index).sorted()
        
        assertSnapshot(matching: besideIndexes, as: .description)
    }
    
    func test_indexesBeside_24() {
        let grid = Grid<TileState>(rows: 10, columns: 10)
        let index = 24
        let besideIndexes = grid.indexes(beside: index).sorted()
        
        assertSnapshot(matching: besideIndexes, as: .description)
    }
    
    func test_indexesBeside_0() {
        let grid = Grid<TileState>(rows: 10, columns: 10)
        let index = 0
        let besideIndexes = grid.indexes(beside: index).sorted()
        
        assertSnapshot(matching: besideIndexes, as: .description)
    }
    
    func test_indexesBeside_10() {
        let grid = Grid<TileState>(rows: 10, columns: 10)
        let index = 9
        let besideIndexes = grid.indexes(beside: index).sorted()
        
        assertSnapshot(matching: besideIndexes, as: .description)
    }
    
    func test_fromString_withDescription() {
        let grid = Grid<TileState>.randomGrid()
        let string = grid.description
        let gridFromString = Grid<TileState>.fromDescription(string)
        
        XCTAssertEqual(grid, gridFromString)
    }

}
