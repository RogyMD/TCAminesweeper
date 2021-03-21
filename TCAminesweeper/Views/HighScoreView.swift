//
//  HighScoreView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//

import SwiftUI
import ComposableArchitecture
import HighScoresCore
import TCAminesweeperCommon

public struct HighScoreView: View {
    
    struct RowViewState: Equatable {
        var userName: String
        var score: String
    }
    
    public let store: Store<HighScoreState, HighScoreAction>
    
    public init(store: Store<HighScoreState, HighScoreAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                Section(
                    header: Picker(
                        selection: viewStore.binding(get: \.difficulty, send: HighScoreAction.difficultyChanged),
                        label: EmptyView()
                    ) {
                        ForEach(viewStore.categories, id: \.self) { category in
                            Text(category.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(5)
                ) {
                    ForEachStore(self.store.scope(state: \.scores, action: HighScoreAction.scoreAction)) { store in
                        WithViewStore(store.scope(state: \.value.view)) { viewStore in
                            rowView(viewStore: viewStore)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .onAppear { viewStore.send(.loadScores) }
            .navigationTitle("High Scores")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { viewStore.send(.cancelButtonTapped) }
                }
            }
        }
    }
    
    func rowView(viewStore: ViewStore<RowViewState, Never>) -> some View {
        HStack {
            Text(viewStore.userName)
            Spacer()
            Text(viewStore.score)
        }
    }
}

extension UserHighScore {
    var view: HighScoreView.RowViewState {
        HighScoreView.RowViewState(
            userName: userName ?? "No name",
            score: String(score)
        )
    }
}

#if DEBUG

struct HighScoreView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoreView(
            store: Store(
                initialState: HighScoreState(difficulty: .normal),
                reducer: highScoreReducer,
                environment: .preview
            )
        )
    }
}

#endif
