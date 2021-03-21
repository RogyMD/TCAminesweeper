//
//  HighScoreService.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 09/03/2021.
//

import ComposableArchitecture
import TCAminesweeperCommon

public struct HighScoreService {
    public var isScoreInTop10: (Difficulty, Int) -> Effect<Bool, Never>
    public var scores: (Difficulty) -> Effect<[UserHighScore], Never>
    public var saveScore: (UserHighScore, Difficulty) -> Effect<Never, Never>
    
    public init(
        isScoreInTop10: @escaping (Difficulty, Int) -> Effect<Bool, Never>,
        scores: @escaping (Difficulty) -> Effect<[UserHighScore], Never>,
        saveScore: @escaping (UserHighScore, Difficulty) -> Effect<Never, Never>
    ) {
        self.isScoreInTop10 = isScoreInTop10
        self.scores = scores
        self.saveScore = saveScore
    }
}

#if DEBUG

public extension HighScoreService {
    static func mock(
        isScoreInTop10: @escaping (Difficulty, Int) -> Effect<Bool, Never> = { _,_ in fatalError() },
        scores: @escaping (Difficulty) -> Effect<[UserHighScore], Never> = { _ in fatalError() },
        saveScore: @escaping (UserHighScore, Difficulty) -> Effect<Never, Never> = { _,_ in fatalError() }
    ) -> Self {
        Self(
            isScoreInTop10: isScoreInTop10,
            scores: scores,
            saveScore: saveScore
        )
    }
    
    static  let preview = Self.mock(
        isScoreInTop10: {_,_ in .none },
        scores: {_ in .none},
        saveScore: {_,_ in .none}
    )
}

#endif
