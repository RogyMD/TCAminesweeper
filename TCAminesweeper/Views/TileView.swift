//
//  TileView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import ComposableArchitecture
import TileCore
import SwiftUI
import TCAminesweeperCommon

public struct TileView: View {
    struct ViewState: Equatable {
        var isMine: Bool
        var isEmpty: Bool
        var isHidden: Bool
        var isMarked: Bool
        var text: String
        var textColor: Color
    }
    
    public let store: Store<TileState, TileAction>
    
    public init(store: Store<TileState, TileAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store.scope(state: { $0.view })) { viewStore in
            if viewStore.isHidden {
                OverlayTile(
                    isMarked: viewStore.isMarked,
                    onTap: { viewStore.send(.tapped) },
                    onLongPress: { viewStore.send(.longPressed) }
                )
                    
            } else if viewStore.isMine {
                BombTile(
                    text: viewStore.text,
                    isMarked: viewStore.isMarked
                )
            } else {
                TextTile(
                    text: viewStore.text,
                    textColor: viewStore.textColor
                )
            }
        }
        .frame(width: 30, height: 30)
    }
}

extension TileState {
    var view: TileView.ViewState {
        TileView.ViewState(
            isMine: tile.isMine,
            isEmpty: tile.isEmpty,
            isHidden: isHidden,
            isMarked: isMarked,
            text: tile.description,
            textColor: tile.textColor
        )
    }
}

extension Tile {
    var textColor: Color {
        switch self {
        case .explosion,
             .mine,
             .empty:
            return .black
        case .one:
            return .blue
        case .two:
            return .green
        case .three:
            return .red
        case .four:
            return .darkBlue4
        case .five:
            return .darkRed5
        case .six:
            return .lightBlue6
        case .seven:
            return .black
        case .eight:
            return .secondary
        }
    }
}

#if DEBUG

struct TileView_Previews: PreviewProvider {
    static var previews: some View {
        TileView(
            store: Store(
                initialState: TileState(
                    tile: .mine,
                    isHidden: false,
                    isMarked: false
                ),
                reducer: tileReducer,
                environment: TileEnvironment()
            )
        )
    }
}

#endif
