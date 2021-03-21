//
//  SettingsCore.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 08/03/2021.
//

import ComposableArchitecture
import Foundation
import SettingsService
import TCAminesweeperCommon

public struct SettingsState: Equatable {
    public var userSettings: UserSettings
    public var difficulties: [Difficulty] = [.easy, .normal, .hard, .custom]
    public var difficulty: Difficulty {
        get { userSettings.difficulty }
        set { userSettings.difficulty = newValue }
    }
    public var minefieldAttributes: MinefieldAttributes {
        get { userSettings.minefieldAttributes }
        set { userSettings.minefieldAttributes = newValue }
    }
    
    public init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
}

public enum SettingsAction: Equatable {
    case cancelButtonTapped
    case newGameButtonTapped
    case binding(BindingAction<SettingsState>)
    case saveSettings
}

public struct SettingsEnvironment {
    public var settingsService: SettingsService
    
    public init(settingsService: SettingsService) {
        self.settingsService = settingsService
    }
}

public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, environment in
    switch action {
        
    case .binding(\.difficulty):
        if let attributes = state.difficulty.minefieldAttributes {
            state.minefieldAttributes = attributes
        }
        return Effect(value: .saveSettings)
        
    case .saveSettings:
        return environment.settingsService.saveUserSettings(state.userSettings)
            .fireAndForget()
            .eraseToEffect()
    
    case .binding(\.minefieldAttributes.rows),
         .binding(\.minefieldAttributes.columns),
         .binding(\.minefieldAttributes.mines):
        
        state.minefieldAttributes.normalize()
        return Effect(value: .saveSettings)
        
    case .binding(_):
        return Effect(value: .saveSettings)
        
    case .cancelButtonTapped, .newGameButtonTapped:
        return .none
    }
}
.binding(action: /SettingsAction.binding)

#if DEBUG

public extension SettingsEnvironment {
    static func mock(settingsService: SettingsService = .mock()) -> Self {
        SettingsEnvironment(settingsService: settingsService)
    }
    
    static let preview = Self(settingsService: .preview)
}

#endif
