//
//  AppView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 13/03/2021.
//

import SwiftUI
import ComposableArchitecture
import AppCore
import HighScoresView
import NewGameView
import SettingsView

public struct AppView: View {
    public let store: Store<AppState, AppAction>
    
    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            NewGameView(
                store: self.store.scope(
                    state: \.newGame,
                    action: AppAction.newGameAction
                ))
                .sheet(
                    item: viewStore.binding(
                        get: \.sheet,
                        send: AppAction.dismiss
                    )
                ) { sheet in
                    switch sheet {
                    case .settings:
                        IfLetStore(self.store.scope(state: \.settings, action: AppAction.settingsAction)) { store in
                            NavigationView {
                                SettingsView(store: store)
                            }
                            .navigationViewStyle(StackNavigationViewStyle())
                        }
                    case .highScores:
                        IfLetStore(self.store.scope(state: \.highScores, action: AppAction.highScoresAction)) { store in
                            NavigationView {
                                HighScoreView(store: store)
                            }
                            .navigationViewStyle(StackNavigationViewStyle())
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: { viewStore.send(.settingsButtonTapped) }) {
                            Image(systemName: "gear")
                        }
                        
                        Spacer()
                        
                        Button(action: { viewStore.send(.highScoresButtonTapped) }) {
                            Image(systemName: "list.number")
                        }
                    }
                }
        }
    }
}

#if DEBUG

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(),
                reducer: appReducer,
                environment: .preview
            )
        )
    }
}

#endif
