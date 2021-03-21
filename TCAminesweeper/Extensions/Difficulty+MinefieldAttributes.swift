//
//  Difficulty+MinefieldAttributes.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 14/03/2021.
//

import Foundation

public extension Difficulty {
    var minefieldAttributes: MinefieldAttributes? {
        switch self {
        case .easy:
            return .init(rows: 9, columns: 9, mines: 10)
        case .normal:
            return .init(rows: 16, columns: 16, mines: 40)
        case .hard:
            return .init(rows: 16, columns: 30, mines: 99)
        case .custom:
            return nil
        }
    }
}
