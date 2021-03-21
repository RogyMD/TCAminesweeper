//
//  HighScoreCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import ComposableArchitecture
import HighScoreService
import TCAminesweeperCommon

public struct HighScoreState: Equatable {
    public let categories: [Difficulty] = [.easy, .normal, .hard]
    public var difficulty: Difficulty
    public fileprivate(set) var scores: IdentifiedArrayOf<Identified<Int, UserHighScore>> = []
    
    public init(
        difficulty: Difficulty,
        scores: [UserHighScore] = []
    ) {
        self.difficulty = difficulty
        self.scores = IdentifiedArray(scores.enumerated().map { Identified($1, id: $0) })
    }
}

public enum HighScoreAction: Equatable {
    case difficultyChanged(Difficulty)
    case updateScores([UserHighScore])
    case cancelButtonTapped
    case loadScores
    case scoreAction(Int, Never)
}

public struct HighScoreEnvironment {
    public var highScoreService: HighScoreService
    
    public init(highScoreService: HighScoreService) {
        self.highScoreService = highScoreService
    }
}

public let highScoreReducer = Reducer<HighScoreState, HighScoreAction, HighScoreEnvironment> { state, action, environment in
    switch action {
    case let .difficultyChanged(difficulty):
        state.difficulty = difficulty
        return Effect(value: .loadScores)
        
    case let .updateScores(scores):
        state.scores = IdentifiedArray(scores.sorted(by: { $0.score < $1.score }).enumerated().map { Identified($1, id: $0) })
        return .none
    
    case .loadScores:
        return environment.highScoreService.scores(state.difficulty)
            .map { .updateScores($0) }
        
    case .scoreAction(_, _), .cancelButtonTapped:
        return .none
    }
}

#if DEBUG

public extension HighScoreEnvironment {
    static func mock(highScoreService: HighScoreService = .mock()) -> Self {
        Self(highScoreService: highScoreService)
    }
    
    static let preview = Self(
        highScoreService: .preview
    )
}

#endif
