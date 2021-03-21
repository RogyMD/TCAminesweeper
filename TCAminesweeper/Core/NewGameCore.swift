//
//  NewGameCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 08/03/2021.
//

import Foundation
import ComposableArchitecture
import GameCore
import TCAminesweeperCommon
import HighScoreService
import SettingsService
import MinefieldCore

public struct NewGameState: Equatable {
    public var game: GameState?
    public var showsHighScoreAlert: Bool
    
    public init(
        game: GameState? = nil,
        showsHighScoreAlert: Bool = false
    ) {
        self.game = game
        self.showsHighScoreAlert = showsHighScoreAlert
    }
}

public enum NewGameAction: Equatable {
    case gameAction(GameAction)
    case newGame(GameState)
    case startNewGame
    case showAlert
    case alertActionButtonTapped(String?)
    case dismissAlert
}

public struct NewGameEnvironment {
    let minefieldGenerator: (MinefieldAttributes) -> Effect<MinefieldState, Never>
    let uuid: () -> UUID
    let now: () -> Date
    var game: GameEnvironment
    var settingsService: SettingsService
    var highScoreService: HighScoreService
    
    public init(
        minefieldGenerator: @escaping (MinefieldAttributes) -> Effect<MinefieldState, Never>,
        uuid: @escaping () -> UUID,
        now: @escaping () -> Date,
        game: GameEnvironment,
        settingsService: SettingsService,
        highScoreService: HighScoreService
    ) {
        self.minefieldGenerator = minefieldGenerator
        self.uuid = uuid
        self.now = now
        self.game = game
        self.settingsService = settingsService
        self.highScoreService = highScoreService
    }
}

public let newGameReducer: Reducer<NewGameState, NewGameAction, NewGameEnvironment> = .combine(
    gameReducer
        .optional()
        .pullback(
            state: \.game,
            action: /NewGameAction.gameAction,
            environment: \.game),
        
    Reducer { state, action, environment in
        switch action {
        case .gameAction(.headerAction(.buttonTapped)):
            return Effect(value: .startNewGame)
            
        case let .gameAction(.gameStateChanged(.over(score: score))):
            guard let score = score,
                  let difficulty = state.game?.difficulty
            else { return .none }
            
            return environment.highScoreService.isScoreInTop10(difficulty, score)
                .compactMap { $0 ? .showAlert : nil }
                .eraseToEffect()
            
        case .startNewGame:
            return environment.settingsService.userSettings()
                .flatMap { settings in
                    environment.minefieldGenerator(settings.minefieldAttributes)
                        .map { GameState(difficulty: settings.difficulty, minefieldState: $0) }
                }
                .map(NewGameAction.newGame)
                .eraseToEffect()
            
        case let .newGame(game):
            state.game = game
            return Effect(value: .gameAction(.startNewGame(game.minefieldState)))
            
        case .showAlert:
            state.showsHighScoreAlert = true
            return .none
            
        case let .alertActionButtonTapped(name):
            guard let game = state.game,
                  case let .over(score) = game.gameState,
                  let highScore = score
            else { return .none }
            
            let userScore = UserHighScore(
                id: environment.uuid(),
                score: highScore,
                userName: name,
                date: environment.now()
            )
            
            return environment.highScoreService.saveScore(userScore, game.difficulty)
                .fireAndForget()
                .eraseToEffect()
            
        case .dismissAlert:
            state.showsHighScoreAlert = false
            return .none
            
        case .gameAction(_):
            return .none
        }
    }
)

#if DEBUG

public extension NewGameEnvironment {
    static func mock(
        minefieldGenerator: @escaping (MinefieldAttributes) -> Effect<MinefieldState, Never> = {_ in fatalError()},
        uuid: @escaping () -> UUID = { fatalError() },
        now: @escaping () -> Date = { fatalError() },
        game: GameEnvironment = .mock(),
        settingsService: SettingsService = .mock(),
        highScoreService: HighScoreService = .mock()
    ) -> Self {
        Self(
            minefieldGenerator: minefieldGenerator,
            uuid: uuid,
            now: now,
            game: game,
            settingsService: settingsService,
            highScoreService: highScoreService
        )
    }
    
    static let preview = Self.mock(minefieldGenerator: { _ in .none })
}

#endif
