//
//  Difficulty.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 14/03/2021.
//

import SwiftUI

public enum Difficulty: String, CaseIterable, Hashable, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case custom = "Custom"
    
    public var id: String { rawValue }
    public var isCustom: Bool { self == .custom }
    public var title: String { rawValue }
}
