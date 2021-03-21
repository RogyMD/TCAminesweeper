//
//  MinefieldStateTests.swift
//  MinefieldCoreTests
//
//  Created by Igor Bidiniuc on 20/03/2021.
//

import XCTest
import SnapshotTesting
import TCAminesweeperCommon
@testable import MinefieldCore

class MinefieldStateTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        
//        isRecording = true
    }
    
    func test_reveal() {
        var state = MinefieldState.twoMines
        
        state.reveal(1)
        
        assertSnapshot(matching: state, as: .description)
        
        state.setMarked(true, for: 2)
        state.reveal(2)
        
        assertSnapshot(matching: state, as: .description)
    }
    
    func test_setTile() {
        var state = MinefieldState.twoMines
        
        state.setTile(.eight, for: 0)
        
        assertSnapshot(matching: state, as: .description)
    }
    
    func test_setMarked() {
        var state = MinefieldState.twoMines
        
        state.setMarked(true, for: 0)
        
        assertSnapshot(matching: state, as: .description)
        
        state.setMarked(true, for: 1)
        
        assertSnapshot(matching: state, as: .description)
        
        state.setMarked(false, for: 0)
        
        assertSnapshot(matching: state, as: .description)
    }

}
