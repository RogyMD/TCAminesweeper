//
//  LiveMinefieldEnvironment.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import ComposableArchitecture
import MinefieldCore

extension MinefieldEnvironment {
    static let live = Self(
        tileTappedHandler: { index, state in
            guard let result = Self.tileTappedHandler(index: index, state: &state) else { return .none }
            return Effect(value: result)
        }
    )
    
    static func tileTappedHandler(index: Int, state: inout MinefieldState) -> MinefieldState.Result? {
        let tileState = state.grid.content[index]
        guard !tileState.isMarked else { return nil }
        
        guard !tileState.tile.isMine else {
            prepareStateForLoss(state: &state, mineIndex: index)
            
            return .lost
        }
        
        state.reveal(index)
        
        if tileState.tile.isEmpty {
            revealTilesBesideTile(at: index, state: &state)
        }
        
        let isWin = state.gridInfo.mines.count == state.grid.content.count - state.gridInfo.revealed.count
        if isWin {
            prepareStateForWin(state: &state)
            
            return .win
        } else {
            return nil
        }
    }
    
    static func prepareStateForLoss(state: inout MinefieldState, mineIndex: Int) {
        state.setTile(.explosion, for: mineIndex)
        
        let unflaggedMines = state.gridInfo.mines.filter { !state.gridInfo.flagged.contains($0) }
        state.reveal(unflaggedMines)
        state.gridInfo.flagged.forEach {
            if !state.gridInfo.mines.contains($0) {
                state.setWrongFlag(for: $0)
            }
        }
    }
    
    static func prepareStateForWin(state: inout MinefieldState) {
        let unflaggedMines = state.gridInfo.mines.filter { !state.gridInfo.flagged.contains($0) }
        unflaggedMines.forEach { state.setMarked(true, for: $0) }
    }
    
    static func revealTilesBesideTile(at index: Int, state: inout MinefieldState) {
        var cache: Set<Int> = []
        
        func revealTiles(index: Int) {
            state.reveal(index)
            
            state.grid.indexes(beside: index).forEach { neighbour in
                state.reveal(neighbour)

                if !cache.contains(neighbour) && state.grid.content[neighbour].tile.isEmpty {
                    cache.insert(neighbour)
                    
                    revealTiles(index: neighbour)
                }
            }
        }
        
        revealTiles(index: index)
    }
}
