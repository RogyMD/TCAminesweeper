//
//  Grid.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 07/03/2021.
//

import Foundation
import ComposableArchitecture

public struct Grid<Content>: Equatable where Content: Identifiable & Equatable {
    public let rows: Int
    public let columns: Int
    public var content: IdentifiedArrayOf<Content>
    public var isValid: Bool { content.count == rows * columns }
    
    public init(
        rows: Int,
        columns: Int,
        content: [Content] = []
    ) {
        self.rows = rows
        self.columns = columns
        self.content = IdentifiedArray(content)
    }
}

public extension Grid {
    struct Position: Hashable {
        public var row: Int
        public var column: Int
    }
    
    func indexes(beside index: Int) -> [Int] {
        positions(beside: position(for: index))
            .map { self.index(for: $0) }
    }
    
    func index(for position: Position) -> Int {
        return position.row * columns + position.column
    }
    
    func position(for index: Int) -> Position {
        Position(row: index / columns, column: index % columns)
    }
    
    func positions(beside position: Position) -> Set<Position> {
        let atTopMargin = position.row == 0
        let atBottomMargin = position.row == (rows - 1)
        let atLeadingMargin = position.column == 0
        let atTrailingMargin = position.column == (columns - 1)
        
        var positions: [Position] = []
        
        if !atLeadingMargin {
            positions.append(position.decrease(\.column))
            
            if !atTopMargin { positions.append(position.decrease(\.row).decrease(\.column)) }
            if !atBottomMargin { positions.append(position.increase(\.row).decrease(\.column)) }
        }
        
        if !atTopMargin { positions.append(position.decrease(\.row)) }
        
        if !atBottomMargin { positions.append(position.increase(\.row)) }
        
        if !atTrailingMargin {
            positions.append(position.increase(\.column))
            
            if !atTopMargin { positions.append(position.decrease(\.row).increase(\.column)) }
            if !atBottomMargin { positions.append(position.increase(\.row).increase(\.column)) }
        }
        
        return Set(positions)
    }
}

private extension Grid.Position {
    func decrease(_ kp: WritableKeyPath<Self, Int>) -> Self {
        var position = self
        position[keyPath: kp] -= 1
        return position
    }
    
    func increase(_ kp: WritableKeyPath<Self, Int>) -> Self {
        var position = self
        position[keyPath: kp] += 1
        return position
    }
}
