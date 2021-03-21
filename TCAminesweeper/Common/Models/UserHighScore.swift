//
//  UserHighScore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 11/03/2021.
//

import Foundation

public struct UserHighScore: Codable, Equatable {
    public let id: UUID
    public var score: Int
    public var userName: String?
    public var date: Date
    
    public init(
        id: UUID,
        score: Int,
        userName: String?,
        date: Date = Date()
    ) {
        self.id = id
        self.score = score
        self.userName = userName
        self.date = date
    }
}
