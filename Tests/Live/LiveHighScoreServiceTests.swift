//
//  LiveHighScoreServiceTests.swift
//  TCAminesweeperTests
//
//  Created by Igor Bidiniuc on 18/03/2021.
//

import XCTest
import Combine
import ComposableArchitecture
import HighScoreService
import TCAminesweeperCommon
@testable import LiveHighScoreService

class LiveHighScoreServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    private var databaseMock: HighScoreDatabaseMock!
    var sut: HighScoreService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        databaseMock = HighScoreDatabaseMock()
        HighScoreService.liveDatabase = databaseMock
        
        sut = .live
    }

    override func tearDownWithError() throws {
        databaseMock = nil
        sut = nil
        cancellables = []
        
        try super.tearDownWithError()
    }
    
    func testIsScoreInTop10_Custom_ReturnsNone() {
        var isComplete = false
        var values: [Bool] = []
        sut.isScoreInTop10(.custom, 10)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: { values.append($0) })
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertTrue(values.isEmpty)
    }
    
    func test_isScoreInTop10_Easy_FiveScores_ReturnsTru() {
        databaseMock.highScores = Array(repeating: UserHighScore.mock(score: 10), count: 5)
        var isComplete = false
        var values: [Bool] = []
        
        sut.isScoreInTop10(.easy, 15)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: { values.append($0) })
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(values, [true])
    }
    
    func test_isScoreInTop10_Easy_TensScores_ReturnsFalse() {
        databaseMock.highScores = Array(repeating: UserHighScore.mock(score: 10), count: 10)
        var isComplete = false
        var values: [Bool] = []
        
        sut.isScoreInTop10(.easy, 11)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: { values.append($0) })
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(values, [false])
    }
    
    func test_isScoreInTop10_Easy_TensScores_ReturnsTrue() {
        databaseMock.highScores = Array(repeating: UserHighScore.mock(score: 10), count: 10)
        var isComplete = false
        var values: [Bool] = []
        
        sut.isScoreInTop10(.easy, 9)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: { values.append($0) })
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(values, [true])
    }
    
    func test_scores() {
        databaseMock.highScores = Array(repeating: UserHighScore.mock(score: 10), count: 5)
        var isComplete = false
        var values: [[UserHighScore]] = []
        
        sut.scores(.easy)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: { values.append($0) })
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(values, [databaseMock.highScores])
    }

    func test_saveHighScore_SixScores_SavesAHighScore() {
        let highScore = UserHighScore.mock(score: 10)
        databaseMock.highScores = Array(1...6).map {
            UserHighScore.mock(score: $0)
        }
        var isComplete = false
        
        sut.saveScore(highScore, .easy)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: absurd)
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(
            databaseMock.savedHighScores,
            (databaseMock.highScores + [highScore])
        )
    }
    
    func test_saveHighScore_SixScores_SavesALowScore() {
        let highScore = UserHighScore.mock(score: 10)
        databaseMock.highScores = Array(11...18).map {
            UserHighScore.mock(score: $0)
        }
        var isComplete = false
        
        sut.saveScore(highScore, .easy)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: absurd)
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(
            databaseMock.savedHighScores,
            ([highScore] + databaseMock.highScores)
        )
    }
    
    func test_saveHighScore_SixScores_NotSaveAHighScore() {
        let highScore = UserHighScore.mock(score: 10)
        databaseMock.highScores = Array(0...9).map {
            UserHighScore.mock(score: $0)
        }
        var isComplete = false
        
        sut.saveScore(highScore, .easy)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: absurd)
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(
            databaseMock.savedHighScores,
            databaseMock.highScores
        )
    }
    
}

private final class HighScoreDatabaseMock: HighScoreDatabaseProtocol {
    
    var highScores: [UserHighScore] = []
    var savedHighScores: [UserHighScore]?
    
    func highScores(for difficulty: Difficulty) -> [UserHighScore] {
        return self.highScores
    }
    
    func saveHighScores(_ scores: [UserHighScore], for difficulty: Difficulty) {
        self.savedHighScores = scores
    }
    
}

private extension UUID {
  // A deterministic, auto-incrementing "UUID" generator for testing.
  static var incrementing: () -> UUID {
    var uuid = 0
    return {
      defer { uuid += 1 }
      return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuid))")!
    }
  }
}

private extension UserHighScore {
    static func mock(
        id: UUID = UUID.incrementing(),
        score: Int,
        userName: String? = nil,
        date: Date = Date()
    ) -> Self {
        Self(
            id: id,
            score: score,
            userName: userName,
            date: date
        )
    }
}

private let absurd: (Never) -> Void = { _ in }
