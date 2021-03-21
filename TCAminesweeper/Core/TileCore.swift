//
//  TileCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import Foundation
import ComposableArchitecture

public enum Tile: Int, CaseIterable {
    case explosion = -2
    case mine = -1
    case empty = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    
    public var isMine: Bool { self == .mine }
    public var isEmpty: Bool { self == .empty }
    public var next: Tile { Tile(rawValue: rawValue + 1) ?? .explosion }
}

public struct TileState: Equatable, Identifiable {
    
    public let id: Int
    public var tile: Tile
    public var isHidden: Bool
    public var isMarked: Bool
    
    public init(
        id: Int = UUID().hashValue,
        tile: Tile,
        isHidden: Bool = true,
        isMarked: Bool = false
    ) {
        self.id = id
        self.tile = tile
        self.isHidden = isHidden
        self.isMarked = isMarked
    }
}

public enum TileAction: Equatable {
    case tapped
    case longPressed
}

public struct TileEnvironment {
    public init() {}
}

public let tileReducer = Reducer<TileState, TileAction, TileEnvironment>.empty

extension Tile: CustomStringConvertible {
    public static func fromString(_ string: String) -> Self? {
        switch string {
        case "💥":
            return .explosion
        case "💣":
            return .mine
        case " ":
            return .empty
        default:
            guard let intValue = Int(string), let tile = Tile(rawValue: intValue) else { return nil }
            return tile
        }
    }
    
    public var description: String {
        switch self {
        case .explosion:
            return "💥"
        case .mine:
            return "💣"
        case .empty:
            return " "
        case .one, .two, .three, .four, .five, .six, .seven, .eight:
            return String(rawValue)
        }
    }
}
