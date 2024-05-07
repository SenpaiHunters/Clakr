//
//  ExtensionValues.swift
//  clakr
//
//  Created by Kami on 8/4/2024.
//

import Foundation
import KeyboardShortcuts
import SwiftUI
import AppKit

extension NSSound {
    // Dynamically fetch system sounds
    static var systemSounds: [String] {
        let fileManager = FileManager.default
        let systemSoundsPath = "/System/Library/Sounds"
        do {
            let soundFiles = try fileManager.contentsOfDirectory(atPath: systemSoundsPath)
            let soundNames = soundFiles.compactMap { $0.components(separatedBy: ".").first }
            return soundNames
        } catch {
            print("Error fetching system sounds: \(error)")
            return []
        }
    }
    
    static var customSounds: [String] {
        guard let customSoundURLs = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) else {
            print("No custom sounds found")
            return []
        }
        let customSoundNames = customSoundURLs.compactMap { $0.deletingPathExtension().lastPathComponent }
        return customSoundNames
    }
    
    // Combine system and custom sounds
    static var allSounds: [String] {
        return systemSounds + customSounds
    }
}

func playSound(name: String) {
    guard let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") else {
        print("Sound file not found")
        return
    }
    let sound = NSSound(contentsOf: soundURL, byReference: true)
    sound?.play()
}

// MARK: ContentView Toggle
// Click on/off
extension View {
  func configureAccessibility(isClicking: Bool) -> some View {
    self.accessibilityLabel(isClicking ? "Stop clicking" : "Start clicking")
      .accessibilityHint("Toggles the auto-clicker on or off")
      .accessibilityAddTraits(.isButton)
  }
}

// Ensure the CPS only accepts a numerical set
extension String {
    var isNumeric: Bool {
        return !self.isEmpty && self.allSatisfy { $0.isNumber }
    }
}

// MARK: Keyboard shortcuts
extension KeyboardShortcuts.Name {
  static let toggleAutoClicker = Self("toggleAutoClicker")
  static let openSettingsShortcut = Self("openSettingsShortcut")
}

extension Notification.Name {
  static let showSettings = Notification.Name("ShowSettingsNotification")
  static let toggleMenuBarMode = Notification.Name("ToggleMenuBarModeNotification")
}

extension ContentView {
  class ViewModel: ObservableObject {
    @Published var showingSettings = false
    // @Published var showApp = false
    @Published var showSettings = false

    func toggleSettings() {
      showingSettings.toggle()
    }
  }
}

// MARK: Menu bar
extension MenuManager: NSMenuDelegate {
  func menuWillOpen(_ menu: NSMenu) {
    // This ensures the menu items are validated each time the menu is opened
    menu.autoenablesItems = false
  }

  func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    // Enable the "Settings" menu item if it's the one being validated
    if menuItem.action == #selector(openSettings) {
      return true
    }
    // For all other items, return their original state
    return menuItem.isEnabled
  }
}

// MARK: Blacklisted apps
// Helper extension to encode and decode arrays to/from JSON strings
extension Array where Element: Codable {
  func jsonString() -> String? {
    do {
      let data = try JSONEncoder().encode(self)
      return String(data: data, encoding: .utf8)
    } catch {
      print("Error encoding array to JSON string: \(error)")
      return nil
    }
  }

  static func from(jsonString: String) -> [Element]? {
    do {
      guard let data = jsonString.data(using: .utf8) else { return nil }
      return try JSONDecoder().decode([Element].self, from: data)
    } catch {
      print("Error decoding JSON string to array: \(error)")
      return nil
    }
  }
}

// String extension for deleting suffix
extension String {
  func deletingSuffix(_ suffix: String) -> String {
    guard hasSuffix(suffix) else { return self }
    return String(dropLast(suffix.count))
  }
}

// MARK: Localisation
extension String {
    func localized(using languageCode: String) -> String {
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self // Fallback to the original string
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
