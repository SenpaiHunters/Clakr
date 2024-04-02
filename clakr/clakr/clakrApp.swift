//
//  clakrApp.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import Cocoa
import SwiftUI

@main
struct clakrApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear(perform: configureWindowButtons)
    }
  }

  // Traffic Lights + Top config
  private func configureWindowButtons() {
    guard let window = NSApplication.shared.windows.first else { return }

    window.standardWindowButton(.closeButton)?.isEnabled = true
    window.standardWindowButton(.miniaturizeButton)?.isEnabled = true
    window.standardWindowButton(.zoomButton)?.isEnabled = false

    // Hide the title bar but keep the window buttons
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden

    // Make the window's title bar part of the content view and ensure the buttons are movable
    window.styleMask.insert(.fullSizeContentView)
  }

  private func checkAccessibilityPermissions() {
    let options =
      [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    guard !AXIsProcessTrustedWithOptions(options) else { return }

    let alert = NSAlert()
    alert.messageText = "Accessibility Permission Required"
    alert.informativeText =
      "Please grant accessibility permissions for clakr to function properly. This is needed to simulate mouse clicks."
    alert.alertStyle = .critical
    alert.addButton(withTitle: "Open System Preferences")
    alert.addButton(withTitle: "Cancel")

    let systemPreferencesURLString =
      "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    if alert.runModal() == .alertFirstButtonReturn,
      let url = URL(string: systemPreferencesURLString)
    {
      NSWorkspace.shared.open(url)
    }
  }
}
