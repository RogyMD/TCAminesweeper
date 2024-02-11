//
//  LiveHighScoreService.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//
import Foundation
import ComposableArchitecture
import HighScoreService
import TCAminesweeperCommon

extension HighScoreService {
    static var liveDatabase: HighScoreDatabaseProtocol = UserDefaults.standard
    
    static let live = Self(
        isScoreInTop10: { difficulty, score in
            guard difficulty != .custom else { return .none }
            
            return Effect.result {
                let scores = liveDatabase.highScores(for: difficulty)
                return .success(scores.count < 10 ? true : score < (scores.last?.score ?? Int.max))
            }
        },
        scores: { difficulty in
            Effect.result {
                return .success(liveDatabase.highScores(for: difficulty))
            }
        },
        saveScore: { userScore, difficulty  in
            .fireAndForget {
                guard difficulty != .custom else { assertionFailure(); return }
                
                var scores = liveDatabase.highScores(for: difficulty)
                scores.append(userScore)
                let top10 = Array(scores.sorted(by: { $0.score < $1.score }).prefix(10))
                liveDatabase.saveHighScores(top10, for: difficulty)
            }
        }
    )
}

protocol HighScoreDatabaseProtocol {
    func highScores(for difficulty: Difficulty) -> [UserHighScore]
    func saveHighScores(_ scores: [UserHighScore], for difficulty: Difficulty)
}

extension UserDefaults: HighScoreDatabaseProtocol {
    private static func highScoresKey(for difficulty: Difficulty) -> String {
        "\(difficulty.rawValue)-HighScores"
    }
    
    func highScores(for difficulty: Difficulty) -> [UserHighScore] {
        guard let data = object(forKey: Self.highScoresKey(for: difficulty)) as? Data else { return [] }
        do {
            return try JSONDecoder().decode([UserHighScore].self, from: data)
        } catch {
            #if DEBUG
            NSLog("Failed to decode UserSettings. Error: \(error.localizedDescription)")
            #endif
            clean(for: difficulty)
            return []
        }
    }
    
    func saveHighScores(_ scores: [UserHighScore], for difficulty: Difficulty) {
        let data = try? JSONEncoder().encode(scores)
        set(data, forKey: Self.highScoresKey(for: difficulty))
    }
    
    private func clean(for difficulty: Difficulty) {
        removeObject(forKey: Self.highScoresKey(for: difficulty))
    }
}
