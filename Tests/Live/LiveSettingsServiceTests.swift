//
//  LiveSettingsServiceTests.swift
//  TCAminesweeperTests
//
//  Created by Igor Bidiniuc on 18/03/2021.
//

import XCTest
import Combine
import ComposableArchitecture
import SettingsService
import TCAminesweeperCommon
@testable import LiveSettingsService

class LiveSettingsServiceTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []
    
    private var databaseMock: SettingsDatabaseMock!
    var sut: SettingsService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        databaseMock = SettingsDatabaseMock()
        SettingsService.liveDatabase = databaseMock
        
        sut = .live
    }

    override func tearDownWithError() throws {
        databaseMock = nil
        sut = nil
        cancellables = []
        
        try super.tearDownWithError()
    }
    
    func test_userSettings_Nil_ReturnsDefault() {
        var isComplete = false
        var values: [UserSettings] = []
        
        sut.userSettings()
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: { values.append($0) })
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(values, [.default])
    }
    
    func test_userSettings_SomeSettings_ReturnsSomeSettings() {
        let otherSettings = UserSettings(otherThanCustom: .hard)
        databaseMock.userSettingsReturnValue = otherSettings
        var isComplete = false
        var values: [UserSettings] = []
        
        sut.userSettings()
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: { values.append($0) })
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(values, [otherSettings])
    }
    
    func test_saveUserSettings() {
        var isComplete = false
        
        sut.saveUserSettings(.default)
            .sink(receiveCompletion: { _ in isComplete = true }, receiveValue: absurd)
            .store(in: &cancellables)
        
        XCTAssertTrue(isComplete)
        XCTAssertEqual(databaseMock.savedUserSettings, .default)
    }
}

private final class SettingsDatabaseMock: SettingsDatabaseProtocol {
    var userSettingsReturnValue: UserSettings?
    var savedUserSettings: UserSettings?
    
    func userSettings() -> UserSettings? {
        userSettingsReturnValue
    }
    
    func saveUserSettings(_ settings: UserSettings) {
        self.savedUserSettings = settings
    }
}

private let absurd: (Never) -> Void = { _ in }
