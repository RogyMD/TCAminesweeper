//
//  Shuffler.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 21/03/2021.
//

import Foundation

public struct Shuffler<T> {
    public let shuffle: ([T]) -> [T]
    
    public init(shuffle: @escaping ([T]) -> [T]) {
        self.shuffle = shuffle
    }
}

public extension Shuffler where T == Int {
    static let random = Self(shuffle: { $0.shuffled() })
}
