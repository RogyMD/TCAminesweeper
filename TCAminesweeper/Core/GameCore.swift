//
//  GameCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import UIKit
import SettingsService
import MinefieldCore
import ComposableArchitecture
import TCAminesweeperCommon

public struct GameState: Equatable {
    public enum State: Equatable {
        case new
        case inProgress(Int)
        case over(score: Int?)
    }
    
    public var difficulty: Difficulty
    public var headerState: HeaderState
    public var gameState: State
    public var minefieldState: MinefieldState
    
    public init(
        difficulty: Difficulty,
        minefieldState: MinefieldState
    ) {
        self.difficulty = difficulty
        self.minefieldState = minefieldState
        self.headerState = HeaderState(
            leadingText: String(format: "%03d", minefieldState.gridInfo.mines.count),
            centerText: "😴",
            trailingText: "000"
        )
        self.gameState = .new
    }
}

public enum GameAction: Equatable {
    case headerAction(HeaderAction)
    case minefieldAction(MinefieldAction)
    case gameStateChanged(GameState.State)
    case updateRemainedMines
    case startNewGame(MinefieldState)
    case gameStarted
    case timerUpdated
    case onDisappear
    case onAppear
}

public struct GameEnvironment {
    public typealias NotificationFeedbackType = UINotificationFeedbackGenerator.FeedbackType
    public let minefieldEnvironment: MinefieldEnvironment
    public let timerScheduler: AnySchedulerOf<DispatchQueue>
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let selectionFeedback: () -> Effect<Never, Never>
    public let notificationFeedback: (NotificationFeedbackType) -> Effect<Never, Never>
    
    public init(
        minefieldEnvironment: MinefieldEnvironment,
        timerScheduler: AnySchedulerOf<DispatchQueue>,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        selectionFeedback: @escaping () -> Effect<Never, Never>,
        notificationFeedback: @escaping (NotificationFeedbackType) -> Effect<Never, Never>
    ) {
        self.minefieldEnvironment = minefieldEnvironment
        self.timerScheduler = timerScheduler
        self.mainQueue = mainQueue
        self.selectionFeedback = selectionFeedback
        self.notificationFeedback = notificationFeedback
    }
}

private struct ScoreTimerId: Hashable {}

public let gameReducer: Reducer<GameState, GameAction, GameEnvironment> = .combine(
    headerReducer
        .pullback(
            state: \.headerState,
            action: /GameAction.headerAction,
            environment: { _ in () }),
    
    minefieldReducer
        .pullback(
            state: \.minefieldState,
            action: /GameAction.minefieldAction,
            environment: \.minefieldEnvironment),
    
    Reducer { state, action, environment in
        switch action {
            
        case let .minefieldAction(minefieldAction):
            switch minefieldAction {
            case .tile(_, _):
                guard state.gameState == .new else { return .none }
                
                return .merge(
                    Effect(value: .gameStateChanged(.inProgress(0))),
                    Effect(value: .updateRemainedMines)
                )
                
            case .toogleMark(_):
                return .merge(
                    environment.selectionFeedback().fireAndForget(),
                    Effect(value: .updateRemainedMines)
                )
                
            case let .resultChanged(result):
                guard let result = result else { return .none }
                var score: Int? = nil
                if case let .inProgress(currentScore) = state.gameState, result.isWin  {
                    score = currentScore
                }
                return Effect(value: .gameStateChanged(.over(score: score)))
            }
            
        case let .startNewGame(newMinefield):
            state.minefieldState = newMinefield
            
            return .merge(
                Effect.cancel(id: ScoreTimerId()),
                Effect(value: .gameStateChanged(.new))
            )
            
        case .updateRemainedMines:
            let remainedMines = state.minefieldState.gridInfo.mines.count - state.minefieldState.gridInfo.flagged.count
            state.headerState.leadingText = String(format: "%03d", remainedMines)
            return .none
            
        case let .gameStateChanged(newGameState):
            state.gameState = newGameState
            switch newGameState {
            case .new:
                state.headerState.leadingText = String(format: "%03d", state.minefieldState.gridInfo.mines.count)
                state.headerState.centerText = "😴"
                state.headerState.trailingText = "000"
                return .none
                
            case .inProgress(_):
                return Effect(value: .gameStarted)
                
            case let .over(score):
                let notification: GameEnvironment.NotificationFeedbackType
                if let score = score {
                    state.headerState.trailingText = String(format: "%03d", score)
                    state.headerState.centerText = "😎"
                    notification = .success
                } else {
                    state.headerState.centerText =  "🤯"
                    notification = .error
                }
                
                return .merge(
                    environment.notificationFeedback(notification).fireAndForget(),
                    .cancel(id: ScoreTimerId())
                )
            }
            
        case .gameStarted:
            if case .inProgress(_) = state.gameState {
                state.headerState.centerText = "🙂"
            }
            
            return .merge(
                .cancel(id: ScoreTimerId()),
                Effect
                    .timer(id: ScoreTimerId(), every: 1, on: environment.timerScheduler)
                    .map { _ in .timerUpdated }
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
            )
            
        case .timerUpdated:
            guard case let .inProgress(score) = state.gameState else { return .cancel(id: ScoreTimerId()) }
            let newScore = score + 1
            state.gameState = .inProgress(newScore)
            state.headerState.trailingText = String(format: "%03d", newScore)
            return .none
            
        case .onDisappear:
            return .cancel(id: ScoreTimerId())
        
        case .onAppear:
            switch state.gameState {
            case .inProgress(_):
                return Effect(value: .gameStarted)
            default:
                return .none
            }
            
        case .headerAction(_):
            return .none
        }
        
    }
)

#if DEBUG

public extension GameEnvironment {
    static func mock(
        minefieldEnvironment: MinefieldEnvironment = .mock(),
        timerScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        selectionFeedback: @escaping () -> Effect<Never, Never> = { fatalError() },
        notificationFeedback: @escaping (NotificationFeedbackType) -> Effect<Never, Never> = { _ in fatalError() }
    ) -> Self {
            Self(
                minefieldEnvironment: minefieldEnvironment,
                timerScheduler: timerScheduler,
                mainQueue: mainQueue,
                selectionFeedback: selectionFeedback,
                notificationFeedback: notificationFeedback
            )
    }
    
    static let preview = Self.mock()
}

#endif
