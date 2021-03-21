//
//  MinefieldAttributesTests.swift
//  MinefieldCoreTests
//
//  Created by Igor Bidiniuc on 20/03/2021.
//

import XCTest
import TCAminesweeperCommon
import SnapshotTesting
@testable import SettingsCore

class MinefieldAttributesTests: XCTestCase {

    func test_normalize_big() {
        var attributes = MinefieldAttributes(rows: 100, columns: 100, mines: 100*100)
        attributes.normalize()
        assertSnapshot(matching: attributes, as: .description)
    }
    
    func test_normalize_small() {
        var attributes = MinefieldAttributes(rows: 1, columns: 1, mines: 0)
        attributes.normalize()
        assertSnapshot(matching: attributes, as: .description)
    }

    func test_normalize_normal() {
        var attributes = MinefieldAttributes(rows: 10, columns: 10, mines: 10)
        attributes.normalize()
        assertSnapshot(matching: attributes, as: .description)
    }
    
    func test_range_rows() {
        let attributes = MinefieldAttributes(rows: 10, columns: 10, mines: 10)
        let range = attributes.range(forKeyPath: \.rows)
        assertSnapshot(matching: range, as: .description)
    }
    
    func test_range_columns() {
        let attributes = MinefieldAttributes(rows: 10, columns: 10, mines: 10)
        let range = attributes.range(forKeyPath: \.columns)
        assertSnapshot(matching: range, as: .description)
    }
    
    func test_range_mines() {
        let attributes = MinefieldAttributes(rows: 10, columns: 10, mines: 10)
        let range = attributes.range(forKeyPath: \.mines)
        assertSnapshot(matching: range, as: .description)
    }
}
