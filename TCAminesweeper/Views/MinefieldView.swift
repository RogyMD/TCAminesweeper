//
//  MinefieldView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import ComposableArchitecture
import SwiftUI
import TileCore
import TileView
import MinefieldCore

public struct MinefieldView: View {
    public let store: Store<MinefieldState, MinefieldAction>
    
    public init(store: Store<MinefieldState, MinefieldAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView([.horizontal, .vertical]) {
                LazyVGrid(columns: self.gridItems(for: viewStore.grid.columns), spacing: 0) {
                    ForEachStore(self.store.scope(state: \.grid.content, action: MinefieldAction.tile)) { store in
                        TileView(store: store)
                    }
                }
                .disabled(viewStore.isDisabled)
                .padding()
            }
        }
    }
    
    private func gridItems(for columns: Int) -> [GridItem] {
        Array(
            repeating: GridItem(.fixed(30), spacing: 0),
            count: columns
        )
    }
}

extension MinefieldState {
    var isDisabled: Bool { result != nil }
}

#if DEBUG
import TCAminesweeperCommon

struct MinefieldView_Previews: PreviewProvider {
    static var previews: some View {
        MinefieldView(
            store: Store(
                initialState: MinefieldState(
                    grid: Grid(
                        rows: 2,
                        columns: 2,
                        content: Grid.twoMines.content.map { TileState(id: $0.id, tile: $0.tile, isHidden: false, isMarked: false) }
                    )
                ),
                reducer: minefieldReducer,
                environment: .preview))
    }
}

#endif
