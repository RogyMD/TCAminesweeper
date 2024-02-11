//
//  LiveNewGameEnvironment.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//
import Foundation
import ComposableArchitecture
import NewGameCore
import TCAminesweeperCommon
import MinefieldCore
import TileCore

extension NewGameEnvironment {
    static let live = Self(
        minefieldGenerator: { attributes in
            Effect(value: Self.minefieldGenerator(attributes, shuffler: .random))
        },
        uuid: UUID.init,
        now: Date.init,
        game: .live,
        settingsService: .live,
        highScoreService: .live
    )
}

extension NewGameEnvironment {
    static func minefieldGenerator(_ attributes: MinefieldAttributes, shuffler: Shuffler<Int> = .random) -> MinefieldState {
        func makeMines(content: inout [Tile]) -> [Int] {
            let mines = Array(shuffler.shuffle(Array(content.indices)).prefix(Int(attributes.mines)))
            mines.forEach { content[$0] = Tile.mine }
            return mines
        }
        
        func makeTiles(mines: [Int], content: inout [Tile]) {
            mines.forEach {
                Grid<TileState>(attributes: attributes)
                    .indexes(beside: $0)
                    .forEach {
                        guard !mines.contains($0) else { return }
                        content[$0] = content[$0].next
                    }
            }
        }
        
        var tiles = Array(repeating: Tile.empty, count: Int(attributes.rows * attributes.columns))
        
        let mines = makeMines(content: &tiles)
        makeTiles(mines: mines, content: &tiles)
        let content = tiles.enumerated().map { TileState(id: $0, tile: $1, isHidden: true, isMarked: false) }
        let grid = Grid(attributes: attributes, content: content)
        
        return MinefieldState(grid: grid, gridInfo: GridInfo(mines: Set(mines)))
    }
}
