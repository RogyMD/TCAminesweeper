//
//  GridInfo.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 19/03/2021.
//

import Foundation

public struct GridInfo: Equatable {
    public let mines: Set<Int>
    public var flagged: Set<Int> = []
    public var revealed: Set<Int> = []
    
    public init(
        mines: Set<Int>,
        flagged: Set<Int> = [],
        revealed: Set<Int> = []
    ) {
        self.mines = mines
        self.flagged = flagged
        self.revealed = revealed
    }
}

extension GridInfo: CustomStringConvertible {
    public var description: String {
        "<GridInfo: mines: \(mines.sorted()); flagged: \(flagged.sorted()); revealed: \(revealed.sorted())"
    }
}
