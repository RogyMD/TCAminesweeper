//
//  LiveSettingsService.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 10/03/2021.
//
import Foundation
import ComposableArchitecture
import TCAminesweeperCommon
import SettingsService

extension SettingsService {
    static var liveDatabase: SettingsDatabaseProtocol = UserDefaults.standard
    
    static let live = Self(
        userSettings: {
            Effect.result { .success(liveDatabase.userSettings() ?? .default) }
            
        },
        saveUserSettings: { userSettings in
            .fireAndForget { liveDatabase.saveUserSettings(userSettings) }
        }
    )
}

protocol SettingsDatabaseProtocol {
    func userSettings() -> UserSettings?
    func saveUserSettings(_ settings: UserSettings)
}

extension UserDefaults: SettingsDatabaseProtocol {
    private static let userSetttingsKey = "UserSettings"
    
    func userSettings() -> UserSettings? {
        guard let data = object(forKey: Self.userSetttingsKey) as? Data else { return nil }
        do {
            return try JSONDecoder().decode(UserSettings.self, from: data)
        } catch {
            #if DEBUG
            print("Failed to decode UserSettings. Error: \(error.localizedDescription)")
            #endif
            clean()
            return nil
        }
        
    }
    
    func saveUserSettings(_ settings: UserSettings) {
        let data = try? JSONEncoder().encode(settings)
        set(data, forKey: Self.userSetttingsKey)
    }
    
    private func clean() {
        removeObject(forKey: Self.userSetttingsKey)
    }
}
