//
//  clakrApp.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import KeyboardShortcuts
import SwiftUI

@main
struct clakrApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showingSettings = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Settings {
            SettingsView(autoClicker: AutoClicker())
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
    }
}
