//
//  LiveHighScoreEnvironment.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import Foundation
import HighScoresCore

extension HighScoreEnvironment {
    static let live = Self(highScoreService: .live)
}
