//
//  MinefieldAttributes+Normalize.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 14/03/2021.
//

import Foundation
import TCAminesweeperCommon

extension MinefieldAttributes {
    private enum Maximum {
        static let rows: UInt = 30
        static let columns: UInt = 30
        static func mines(rows: UInt, columns: UInt) -> UInt {
            return rows * columns - 1
        }
    }
    
    private enum Minimum {
        static let rows: UInt = 3
        static let columns: UInt = 3
        static let mines: UInt = 1
    }
    
    mutating func normalize() {
        rows = min(max(rows, Minimum.rows), Maximum.rows)
        columns = min(max(columns, Minimum.columns), Maximum.columns)
        mines = min(max(mines, Minimum.mines), Maximum.mines(rows: rows, columns: columns))
    }
}

public extension MinefieldAttributes {
    func range(forKeyPath keyPath: KeyPath<MinefieldAttributes, UInt>) -> ClosedRange<UInt> {
        switch keyPath {
        case \.rows:
            return Minimum.rows...Maximum.rows
        case \.columns:
            return Minimum.columns...Maximum.columns
        case \.mines:
            return Minimum.mines...Maximum.mines(rows: rows, columns: columns)
        default:
            return 0...0
        }
    }
}

public extension Grid {
    init(
        attributes: MinefieldAttributes,
        content: [Content] = []
    ) {
        self.init(
            rows: Int(attributes.rows),
            columns: Int(attributes.columns),
            content: content
        )
    }
}
