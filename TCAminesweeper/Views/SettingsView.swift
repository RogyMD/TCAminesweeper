//
//  SettingsView.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 08/03/2021.
//

import SwiftUI
import ComposableArchitecture
import SettingsCore
import TCAminesweeperCommon

public struct SettingsView: View {
    public let store: Store<SettingsState, SettingsAction>
    
    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            Form {
                Section(header: Text("Difficulty")) {
                    Picker(
                        selection: viewStore.binding(keyPath: \.difficulty, send: SettingsAction.binding),
                        label: Text("Difficulty")
                    ) {
                        ForEach(viewStore.difficulties, id: \.self) { difficulty in
                            Text(difficulty.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Customize")) {
                    stepperRow(title: "Rows", keyPath: \.rows, viewStore: viewStore)
                    stepperRow(title: "Columns", keyPath: \.columns, viewStore: viewStore)
                    stepperRow(title: "Mines", keyPath: \.mines, viewStore: viewStore)
                }
                .disabled(viewStore.isCustomizeSectionDisabled)
                
                Section {
                    Button(action: { viewStore.send(.newGameButtonTapped) }) {
                        Text("New game")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewStore.send(.cancelButtonTapped) }
                }
            }
        }
    }
    
    func stepperRow(
        title: String,
        keyPath: WritableKeyPath<MinefieldAttributes, UInt>,
        viewStore: ViewStore<SettingsState, SettingsAction>
    ) -> some View {
        HStack {
            Stepper(
                title,
                value: viewStore.binding(keyPath: appending(to: \.minefieldAttributes, path: keyPath), send: SettingsAction.binding),
                in: viewStore.minefieldAttributes.range(forKeyPath: keyPath)
            )
            Text("\(viewStore[dynamicMember: appending(to: \.minefieldAttributes, path: keyPath)])")
                .bold()
        }
    }
}

extension SettingsState {
    var isCustomizeSectionDisabled: Bool { difficulty != .custom }
}

func appending<Root, Value, AppendedValue>(to root: WritableKeyPath<Root, Value>, path: WritableKeyPath<Value, AppendedValue>) -> WritableKeyPath<Root, AppendedValue> {
    return root.appending(path: path)
}

#if DEBUG

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            store: Store(
                initialState: SettingsState(userSettings: .default),
                reducer: settingsReducer,
                environment: .preview
            )
        )
    }
}

#endif
