//
//  LiveGameEnvironment.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import UIKit
import GameCore

extension GameEnvironment {
    static let live = Self(
        minefieldEnvironment: .live,
        timerScheduler: DispatchQueue(label: "md.rogy.timer", qos: .userInitiated).eraseToAnyScheduler(),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        selectionFeedback: { .fireAndForget { UISelectionFeedbackGenerator().selectionChanged() } },
        notificationFeedback: { notification in .fireAndForget { UINotificationFeedbackGenerator().notificationOccurred(notification) } }
    )
}
