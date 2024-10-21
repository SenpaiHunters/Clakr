//
//  ExtensionValues.swift
//  clakr
//
//  Created by Kami on 8/4/2024.
//

import AppKit
import Foundation
import KeyboardShortcuts
import SwiftUI

// MARK: - NSSound Extensions

extension NSSound {
    static var systemSounds: [String] {
        let systemSoundsPath = "/System/Library/Sounds"
        return (try? FileManager.default.contentsOfDirectory(atPath: systemSoundsPath)
            .compactMap { $0.components(separatedBy: ".").first }) ?? []
    }

    static var customSounds: [String] {
        Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil)?
            .compactMap { $0.deletingPathExtension().lastPathComponent } ?? []
    }

    static var allSounds: [String] { systemSounds + customSounds }
}

// MARK: - Sound Playback

func playSound(name: String) {
    guard let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3"),
          let sound = NSSound(contentsOf: soundURL, byReference: true) else {
        print("Sound file not found or couldn't be loaded")
        return
    }
    sound.play()
}

// MARK: - View Extensions

extension View {
    func configureAccessibility(isClicking: Bool) -> some View {
        accessibilityLabel(isClicking ? "Stop clicking" : "Start clicking")
            .accessibilityHint("Toggles the auto-clicker on or off")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - String Extensions

extension String {
    var isNumeric: Bool { !isEmpty && allSatisfy(\.isNumber) }

    func deletingSuffix(_ suffix: String) -> String {
        hasSuffix(suffix) ? String(dropLast(suffix.count)) : self
    }

    func localized(using languageCode: String) -> String {
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return self }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

// MARK: - Keyboard Shortcuts

extension KeyboardShortcuts.Name {
    static let toggleAutoClicker = Self("toggleAutoClicker")
    static let openSettingsShortcut = Self("openSettingsShortcut")
}

// MARK: - Notification Names

extension Notification.Name {
    static let showSettings = Notification.Name("ShowSettingsNotification")
    static let toggleMenuBarMode = Notification.Name("ToggleMenuBarModeNotification")
}

// MARK: - ContentView ViewModel

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var showingSettings = false
        @Published var showSettings = false

        func toggleSettings() { showingSettings.toggle() }
    }
}

// MARK: - MenuManager

extension MenuManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        menu.autoenablesItems = false
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        menuItem.isEnabled
    }
}

// MARK: - Codable Array Extensions

extension Array where Element: Codable {
    func jsonString() -> String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error encoding to JSON: \(error)")
            return nil
        }
    }

    static func from(jsonString: String) -> [Element]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error converting string to data")
            return nil
        }
        do {
            return try JSONDecoder().decode([Element].self, from: jsonData)
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}
