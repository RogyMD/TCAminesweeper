//
//  MinefieldCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import ComposableArchitecture
import TCAminesweeperCommon
import TileCore

public struct MinefieldState: Equatable {
    public enum Result: Equatable {
        case win
        case lost
        
        public var isWin: Bool { self == .win }
    }
    
    public var grid: Grid<TileState>
    public var gridInfo: GridInfo
    public var result: Result? = nil
    
    public init(
        grid: Grid<TileState>,
        gridInfo: GridInfo
    ) {
        assert(grid.isValid, "invalid grid: \(grid)")
        self.grid = grid
        self.gridInfo = gridInfo
    }
    
    public init(
        grid: Grid<TileState>
    ) {
        assert(grid.isValid, "invalid grid: \(grid)")
        self.grid = grid
        let mines = Set(grid.content.indices.filter { grid.content[$0].tile.isMine } )
        let flagged = Set(grid.content.indices.filter { grid.content[$0].isMarked } )
        let revealed = Set(grid.content.indices.filter { grid.content[$0].isHidden == false } )
        self.gridInfo = GridInfo(mines: mines, flagged: flagged, revealed: revealed)
    }
}

extension MinefieldState: CustomStringConvertible {
    public var description: String {
        "<MinefieldState: " +
            "\ngrid: \(grid)" +
            "\ncontent: \(grid.content)" +
            "\ngridInfo: \(gridInfo)" +
            "\nresult: \(String(describing: result))" + ">"
    }
}

public enum MinefieldAction: Equatable {
    case tile(Int, TileAction)
    case toogleMark(Int)
    case resultChanged(MinefieldState.Result?)
}

public struct MinefieldEnvironment {
    public var tileTappedHandler: (Int, inout MinefieldState) -> Effect<MinefieldState.Result, Never>
    
    public init(
        tileTappedHandler: @escaping (Int, inout MinefieldState) -> Effect<MinefieldState.Result, Never>
    ) {
        self.tileTappedHandler = tileTappedHandler
    }
}

public let minefieldReducer: Reducer<MinefieldState, MinefieldAction, MinefieldEnvironment> = tileReducer
    .forEach(
        state: \.grid.content,
        action: /MinefieldAction.tile,
        environment: { _ in TileEnvironment() }
    )
    .combined(with: Reducer { state, action, environment in
        switch action {
        case let .tile(index, .tapped):
            return environment.tileTappedHandler(index, &state)
                .map { .resultChanged($0) }
            
        case let .tile(index, .longPressed):
            return Effect(value: .toogleMark(index))
            
        case let .toogleMark(index):
            let isMarked = state.grid.content[index].isMarked
            state.setMarked(!isMarked, for: index)
            return .none
           
        case let .resultChanged(result):
            state.result = result
            return.none
        }
    })

public extension MinefieldState {
    mutating func reveal(_ index: Int) {
        self.reveal([index])
    }
    
    mutating func reveal(_ indexes: Set<Int>) {
        gridInfo.revealed.formUnion(indexes)
        gridInfo.flagged.subtract(indexes)
        indexes.forEach { grid.content[$0].isHidden = false }
    }
    
    mutating func setTile(_ newTile: Tile, for index: Int) {
        grid.content[index].tile = newTile
    }
    
    mutating func setMarked(_ isMarked: Bool, for index: Int) {
        grid.content[index].isMarked = isMarked
        if isMarked {
            gridInfo.flagged.insert(index)
        } else {
            gridInfo.flagged.remove(index)
        }
    }
    
    mutating func setWrongFlag(for index: Int) {
        var tileState = grid.content[index]
        tileState.isMarked = true
        tileState.tile = .mine
        tileState.isHidden = false
        grid.content[index] = tileState
    }
}

#if DEBUG

public extension MinefieldState {
    static func randomState(rows: Int = 10, columns: Int = 10) -> Self {
        return Self(grid: .randomGrid(rows: rows, columns: columns))
    }
}

public extension MinefieldEnvironment {
    static func mock(tileTappedHandler: @escaping (Int, inout MinefieldState) -> Effect<MinefieldState.Result, Never> = { _, _ in fatalError() }) -> Self {
        Self(tileTappedHandler: tileTappedHandler)
    }
    
    static let preview = Self.mock(tileTappedHandler: { _, _ in .none })
}

public extension MinefieldState {
    static let oneMine = Self(grid: .oneMine, gridInfo: GridInfo(mines: [1]))
    static let twoMines = Self(grid: .twoMines, gridInfo: GridInfo(mines: [1, 3]))
}

public extension Grid where Content == TileState {
    static let oneMine = Self(
        rows: 2,
        columns: 2,
        content: [
            TileState(id: 0, tile: .one),
            TileState(id: 1, tile: .mine),
            TileState(id: 2, tile: .one),
            TileState(id: 3, tile: .one),
        ]
    )
    static let twoMines = Self(
        rows: 2,
        columns: 2,
        content: [
            TileState(id: 0, tile: .one),
            TileState(id: 1, tile: .mine),
            TileState(id: 2, tile: .one),
            TileState(id: 3, tile: .mine),
        ]
    )
    
    static func randomGrid(
        rows: Int = (3..<20).randomElement()!,
        columns: Int = (3..<20).randomElement()!
    ) -> Self {
        let content = Array(0..<rows*columns).map { id in
            Tile.allCases.randomElement().map { TileState(id: id, tile: $0, isHidden: true, isMarked: false) }!
        }
        return Self(
            rows: rows,
            columns: columns,
            content: content
        )
    }
}

#endif
