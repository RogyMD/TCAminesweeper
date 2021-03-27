//
//  GameView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import ComposableArchitecture
import GameCore
import MinefieldView
import SwiftUI
import TCAminesweeperCommon

public struct GameView: View {
    struct ViewState: Equatable {
        var navigationBarLeadingText: String
        var navigationBarTrailingText: String
        var navigationBarCenterText: String
    }
    
    enum ViewAction {
        case headerButtonTapped
        case onDisappear
        case onAppear
    }
    
    public let store: Store<GameState, GameAction>
    @Environment(\.scenePhase) private var scenePhase
    
    public init(store: Store<GameState, GameAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store.scope(state: { $0.view }, action: GameAction.view)) { viewStore in
            VStack {
                MinefieldView(store: self.store.scope(
                    state: \.minefieldState,
                    action: GameAction.minefieldAction
                ))
            }
            .onChange(of: scenePhase) { newScenePhase in
                if newScenePhase == .active {
                    viewStore.send(.onAppear)
                } else {
                    viewStore.send(.onDisappear)
                }
            }
            .toolbar { self.toolbarContent(viewStore: viewStore) }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.background.ignoresSafeArea())
        }
    }
    
    @ToolbarContentBuilder
    func toolbarContent(viewStore: ViewStore<ViewState, ViewAction>) -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Button(action: { viewStore.send(.headerButtonTapped) }) {
                Text(viewStore.navigationBarCenterText)
                    .font(.header)
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Text(viewStore.navigationBarLeadingText)
                .font(.header)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Text(viewStore.navigationBarTrailingText)
                .font(.header)
        }
    }
}

extension GameState {
    var view: GameView.ViewState {
        GameView.ViewState(
            navigationBarLeadingText: headerState.leadingText,
            navigationBarTrailingText: headerState.trailingText,
            navigationBarCenterText: headerState.centerText
        )
    }
}

extension GameAction {
    static func view(_ localAction: GameView.ViewAction) -> Self {
        switch localAction {
        case .headerButtonTapped:
            return .headerAction(.buttonTapped)
        case .onAppear:
            return .onAppear
        case .onDisappear:
            return .onDisappear
        }
    }
}

#if DEBUG

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(
            store: Store(
                initialState: GameState(
                    difficulty: .easy,
                    minefieldState: .randomState(
                        rows: 10,
                        columns: 10)),
                reducer: gameReducer,
                environment: .preview
            )
        )
    }
}

#endif
