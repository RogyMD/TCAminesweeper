//
//  UserSettings.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import Foundation

public struct UserSettings: Codable, Equatable {
    public var difficulty: Difficulty
    public var minefieldAttributes: MinefieldAttributes
    
    public init(minefieldAttributes: MinefieldAttributes) {
        self.difficulty = .custom
        self.minefieldAttributes = minefieldAttributes
    }
    
    public init(otherThanCustom difficulty: Difficulty) {
        guard let attributes = difficulty.minefieldAttributes else {
            fatalError("The difficulty \(String(describing: difficulty)) doesn't have predefined settings")
        }
        
        self.difficulty = difficulty
        self.minefieldAttributes = attributes
    }
}

public extension UserSettings {
    static let `default` = Self(
        otherThanCustom: .easy
    )
}
