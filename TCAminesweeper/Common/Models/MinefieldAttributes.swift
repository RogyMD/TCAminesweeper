//
//  MinefieldAttributes.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import Foundation

public struct MinefieldAttributes: Equatable, Codable {
    public var rows: UInt
    public var columns: UInt
    public var mines: UInt
    
    public init(
        rows: UInt,
        columns: UInt,
        mines: UInt
    ) {
        self.rows = rows
        self.columns = columns
        self.mines = mines
    }
}

