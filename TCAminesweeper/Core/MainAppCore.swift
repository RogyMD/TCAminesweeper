//
//  MainAppCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 27/03/2021.
//

import ComposableArchitecture
import AppCore

public struct MainAppState: Equatable {
    public internal(set) var app: AppState
    
    public init(app: AppState = .init()) {
        self.app = app
    }
}

public enum MainAppAction: Equatable {
    case appAction(AppAction)
    case newGameCommand
    case settingsCommand
}

public struct MainAppEnvironment {
    public var app: AppEnvironment
    
    public init(app: AppEnvironment) {
        self.app = app
    }
}

public let mainAppReducer: Reducer<MainAppState, MainAppAction, MainAppEnvironment> = .combine(
    appReducer.pullback(
        state: \.app,
        action: /MainAppAction.appAction,
        environment: \.app
    ),
    
    Reducer { state, action, environment in
        switch action {
        case .newGameCommand:
            if state.app.settings != nil {
                return Effect(value: .appAction(.settingsAction(.newGameButtonTapped)))
            } else {
                return Effect(value: .appAction(.newGameAction(.startNewGame)))
            }
            
        case .settingsCommand:
            return Effect(value: .appAction(.settingsButtonTapped))
            
        case .appAction(_):
            return .none
        }
    }
)

#if DEBUG

extension MainAppEnvironment {
    static func mock(app: AppEnvironment = .mock()) -> MainAppEnvironment {
        Self(app: app)
    }
}

#endif
