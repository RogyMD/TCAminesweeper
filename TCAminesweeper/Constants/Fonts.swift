//
//  Fonts.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 06/03/2021.
//

import SwiftUI

public extension Font {
    static var header: Font {
        Font(
            UIFont.monospacedSystemFont(
                ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize,
                weight: .semibold)
        )
    }
}
