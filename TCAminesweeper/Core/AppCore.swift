//
//  AppCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 13/03/2021.
//

import Foundation
import ComposableArchitecture
import SettingsService
import SettingsCore
import HighScoreService
import HighScoresCore
import GameCore
import NewGameCore

public enum SheetState: Int, Identifiable {
    case settings
    case highScores
    
    public var id: Int { rawValue }
}

public struct AppState: Equatable {
    public var newGame: NewGameState = NewGameState()
    public var sheet: SheetState? = nil
    public var settings: SettingsState? = nil
    public var highScores: HighScoreState? = nil
    
    var game: GameState? { newGame.game }
    
    public init(
        newGame: NewGameState = NewGameState(),
        sheet: SheetState? = nil,
        settings: SettingsState? = nil,
        highScores: HighScoreState? = nil
    ) {
        self.newGame = newGame
        self.sheet = sheet
        self.settings = settings
        self.highScores = highScores
    }
}

public enum AppAction: Equatable {
    case newGameAction(NewGameAction)
    case settingsAction(SettingsAction)
    case highScoresAction(HighScoreAction)
    case settingsButtonTapped
    case showSettings(SettingsState)
    case highScoresButtonTapped
    case showHighScores(HighScoreState)
    case dismiss
}

public struct AppEnvironment {
    public var newGame: NewGameEnvironment
    public var settings: SettingsEnvironment
    public var highScores: HighScoreEnvironment
    
    var settingsService: SettingsService { settings.settingsService }
    var highScoreService: HighScoreService { highScores.highScoreService }
    
    public init(
        newGame: NewGameEnvironment,
        settings: SettingsEnvironment,
        highScores: HighScoreEnvironment
    ) {
        self.newGame = newGame
        self.settings = settings
        self.highScores = highScores
    }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    newGameReducer
        .pullback(
            state: \.newGame,
            action: /AppAction.newGameAction,
            environment: \.newGame
        ),
    
    settingsReducer
        .optional()
        .pullback(
            state: \.settings,
            action: /AppAction.settingsAction,
            environment: \.settings),
    
    highScoreReducer
        .optional()
        .pullback(
            state: \.highScores,
            action: /AppAction.highScoresAction,
            environment: \.highScores
        ),
    
    Reducer { state, action, environment in
        switch action {
        case .settingsAction(.newGameButtonTapped):
            return .merge(
                Effect(value: .newGameAction(.startNewGame)),
                Effect(value: .dismiss)
            )
            
        case .settingsButtonTapped:
            return environment.settingsService
                .userSettings()
                .map { .showSettings(SettingsState(userSettings: $0)) }
            
        case let .showSettings(settings):
            state.settings = settings
            state.sheet = .settings
            return Effect(value: .newGameAction(.gameAction(.onDisappear)))
            
        case .highScoresButtonTapped:
            let difficulty = (state.game?.difficulty ?? .custom).isCustom ?
                .easy :
                (state.game?.difficulty ?? .easy)
            
            return environment.highScoreService
                .scores(difficulty)
                .map { .showHighScores(HighScoreState(difficulty: difficulty, scores: $0)) }
            
        case let .showHighScores(highScores):
            state.highScores = highScores
            state.sheet = .highScores
            return Effect(value: .newGameAction(.gameAction(.onDisappear)))
            
        case .highScoresAction(.cancelButtonTapped),
             .settingsAction(.cancelButtonTapped):
            state.sheet = nil
            return .none
            
        case .dismiss:
            state.sheet = nil
            state.settings = nil
            state.highScores = nil
            return Effect(value: .newGameAction(.gameAction(.onAppear)))
            
        case .settingsAction(_),
             .highScoresAction(_),
             .newGameAction(_):
            return .none
        }
    }
)

#if DEBUG

public extension AppEnvironment {
    static func mock(
        newGame: NewGameEnvironment = .mock(),
        settings: SettingsEnvironment = .mock(),
        highScores: HighScoreEnvironment = .mock()
    ) -> Self {
        Self(
            newGame: newGame,
            settings: settings,
            highScores: highScores
        )
    }
    
    static let preview = Self(
        newGame: .preview,
        settings: .preview,
        highScores: .preview
    )
}

#endif
