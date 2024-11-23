//
//  Grid+String.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 20/03/2021.
//

import Foundation
import TileCore
import TCAminesweeperCommon

extension Grid: @retroactive CustomStringConvertible where Content == TileState {
    public var description: String {
        "\n" + String(repeating: "_", count: columns + 1) + "\n" +
        content.enumerated().reduce("") { result, arg1 in
            let (index, state) = arg1
            let tile = state.tile
            let position = self.position(for: index)
            if position.row == 0 && position.column == 0 { return result + "|\(tile.description)" }
            else if position.column == 0 && position.row > 0 { return result + "\n|\(tile.description)" }
            else if position.column == columns - 1 { return result + "\(tile.description)|" }
            else { return result + tile.description }
        } +
        "\n" + String(repeating: "_", count: columns + 1) + "\n"
    }
}

extension Grid where Content == TileState {
    public static func fromDescription(_ description: String) -> Self? {
        let rows = description
            .split(separator: "\n")                                 // split in rows
            .filter { $0.first == "|" }                             // filter rows that don't contain tiles
            .map { $0.compactMap { Tile.fromString(String($0)) } }  // map String to Tile
        guard let columns = rows.first?.count else { return nil }

        var id = 0
        func stateIdFrom0() -> Int { defer { id += 1 }; return id }

        return Self(
            rows: rows.count,
            columns: columns,
            content: description.reduce([], { result, char in
                guard let tile = Tile.fromString(String(char)) else { return result }
                return result + [ TileState(id: stateIdFrom0(), tile: tile, isHidden: true, isMarked: false) ]
            })
        )
    }
}
