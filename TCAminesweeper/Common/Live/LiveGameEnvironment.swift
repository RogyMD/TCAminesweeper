//
//  LiveGameEnvironment.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import Foundation
import GameCore

extension GameEnvironment {
    static let live = Self(
        minefieldEnvironment: .live,
        timerScheduler: DispatchQueue(label: "md.rogy.timer", qos: .background).eraseToAnyScheduler(),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        selectionFeedback: .init(),
        notificationFeedback: .init()
    )
}
