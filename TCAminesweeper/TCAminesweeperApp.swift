//
//  TCAminesweeperApp.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 03/03/2021.
//

import SwiftUI
import ComposableArchitecture
import MainAppScene
import MainAppCore

@main
struct TCAminesweeperApp: App {
    #if targetEnvironment(macCatalyst)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        MainAppScene(store: Store(
            initialState: MainAppState(),
            reducer: mainAppReducer,
            environment: .live
        ))
    }
}

#if targetEnvironment(macCatalyst)
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        builder.remove(menu: .file)
        builder.remove(menu: .edit)
        builder.remove(menu: .format)
        builder.remove(menu: .view)
        builder.remove(menu: .services)
    }
}
#endif
