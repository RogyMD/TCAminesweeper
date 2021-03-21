//
//  RootView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 14/03/2021.
//

import SwiftUI
import AppView
import AppCore
import ComposableArchitecture

struct RootView: View {
    var body: some View {
        AppView(store: Store(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live
        ))
    }
}
