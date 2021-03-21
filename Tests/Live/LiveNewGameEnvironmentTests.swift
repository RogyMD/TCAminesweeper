//
//  LiveNewGameEnvironmentTests.swift
//  TCAminesweeperTests
//
//  Created by Igor Bidiniuc on 18/03/2021.
//

import XCTest
import ComposableArchitecture
import NewGameCore
import SnapshotTesting
import TCAminesweeperCommon
@testable import TCAminesweeper

class LiveNewGameEnvironmentTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
//        isRecording = true
    }
    
    func test_minefieldGenerator() {
        var state = NewGameEnvironment.minefieldGenerator(
            .init(rows: 5, columns: 5, mines: 10),
            shuffler: Shuffler { _ in Array(4..<9) + Array(7..<12) }
        )
        
        assertSnapshot(matching: state, as: .description)
        
        state = NewGameEnvironment.minefieldGenerator(
            .init(rows: 12, columns: 9, mines: 6),
            shuffler: Shuffler { _ in [10, 23, 41, 0, 30, 11] }
        )
        
        assertSnapshot(matching: state, as: .description)
        
        state = NewGameEnvironment.minefieldGenerator(
            .init(rows: 12, columns: 9, mines: 10),
            shuffler: Shuffler { _ in [10, 23, 41, 0, 30, 11, 12, 9, 98, 2] }
        )
        
        assertSnapshot(matching: state, as: .description)
    }
}
