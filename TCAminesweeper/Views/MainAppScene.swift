//
//  MainAppScene.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 27/03/2021.
//

import SwiftUI
import ComposableArchitecture
import MainAppCore
import AppView

public struct MainAppScene: Scene {
    public let store: Store<MainAppState, MainAppAction>
    
    public init(store: Store<MainAppState, MainAppAction>) {
        self.store = store
    }
    
    public var body: some Scene {
        WithViewStore(store) { viewStore in
            WindowGroup {
                AppView(store: self.store.scope(state: \.app, action: MainAppAction.appAction))
            }
            .commands {
                CommandMenu("Game") {
                    Button("New Game") {
                        viewStore.send(.newGameCommand)
                    }
                    .keyboardShortcut("n")

                    Divider()

                    Button("Settings") {
                        viewStore.send(.settingsCommand)
                    }
                    .keyboardShortcut(",")
                }
            }
        }
    }
}

