//
//  HeaderCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import Foundation
import ComposableArchitecture

public struct HeaderState: Equatable {
    public var leadingText: String
    public var centerText: String
    public var trailingText: String
}

public enum HeaderAction: Equatable {
    case buttonTapped
}

public typealias HeaderEnvironment = ()

public let headerReducer = Reducer<HeaderState, HeaderAction, HeaderEnvironment>.empty
