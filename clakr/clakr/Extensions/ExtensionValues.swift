//
//  ExtensionValues.swift
//  clakr
//
//  Created by Kami on 8/4/2024.
//

import Foundation
import KeyboardShortcuts
import SwiftUI

// MARK: AutoClicker sound
extension NSSound {
  static let systemSounds: [String] = {
    let librarySoundsURL = URL(fileURLWithPath: "/System/Library/Sounds")
    let librarySounds = try? FileManager.default.contentsOfDirectory(
      at: librarySoundsURL, includingPropertiesForKeys: nil)
    let soundNames = librarySounds?.map { soundURL in
      soundURL.deletingPathExtension().lastPathComponent
    }
    return soundNames ?? []
  }()
}

// MARK: ContentView Toggle
extension View {
  func configureAccessibility(isClicking: Bool) -> some View {
    self.accessibilityLabel(isClicking ? "Stop clicking" : "Start clicking")
      .accessibilityHint("Toggles the auto-clicker on or off")
      .accessibilityAddTraits(.isButton)
  }
}

// MARK: Keyboard shortcuts
extension KeyboardShortcuts.Name {
  static let toggleAutoClicker = Self("toggleAutoClicker")
  static let openSettingsShortcut = Self(
    "openSettingsShortcut", default: .init(.comma, modifiers: [.command]))
}

extension Notification.Name {
  static let showSettings = Notification.Name("ShowSettingsNotification")
  static let toggleMenuBarMode = Notification.Name("ToggleMenuBarModeNotification")
}

extension ContentView {
  class ViewModel: ObservableObject {
    @Published var showingSettings = false
    @Published var showApp = false
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
