//
//  LiveAppEnvirontment.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 14/03/2021.
//

import Foundation
import AppCore

extension AppEnvironment {
    static let live = Self(
        newGame: .live,
        settings: .live,
        highScores: .live
    )
}
