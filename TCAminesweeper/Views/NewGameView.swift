//
//  NewGameView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 08/03/2021.
//

import SwiftUI
import ComposableArchitecture
import NewGameCore
import GameView
import TCAminesweeperCommon

public struct NewGameView: View {
    struct ViewState {
        var showsHighScoreAlert: Bool
    }
    
    public let store: Store<NewGameState, NewGameAction>
    
    public init(store: Store<NewGameState, NewGameAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            IfLetStore(self.store.scope(state: \.game, action: NewGameAction.gameAction)) { store in
                NavigationView {
                    GameView(store: store)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .alert(
                isPresented: viewStore.binding(get: \.showsHighScoreAlert, send: { $0 ? .showAlert : .dismissAlert }),
                TextAlert(
                    title: "You're in TOP 10!",
                    placeholder: "Name",
                    action: { viewStore.send(.alertActionButtonTapped($0)) }
                )
            )
            .onAppear { viewStore.send(.startNewGame) }
            .ignoresSafeArea()
        }
    }
}

#if DEBUG

struct NewGameView_Previews: PreviewProvider {
    static var previews: some View {
        NewGameView(
            store: Store(
                initialState: NewGameState(),
                reducer: newGameReducer,
                environment: .preview
            )
        )
        .preferredColorScheme(.dark)
    }
}

#endif
