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
        .onAppear {
          checkAccessibilityPermissions()
        }
    }
  }

  private func checkAccessibilityPermissions() {
    let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    let accessEnabled = AXIsProcessTrustedWithOptions([checkOptPrompt: true] as CFDictionary)

    if !accessEnabled {
      // The user will be prompted to grant access. If they have already denied access,
      // we will open System Preferences at the Accessibility section.
      let alert = NSAlert()
      alert.messageText = "Accessibility Permission Required"
      alert.informativeText =
        "Please grant accessibility permissions for the clakr to function properly. This is needed to simulate mouse clicks."
      alert.alertStyle = .critical
      alert.addButton(withTitle: "Open System Preferences")
      alert.addButton(withTitle: "Cancel")

      if alert.runModal() == .alertFirstButtonReturn {
        if let url = URL(
          string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        {
          NSWorkspace.shared.open(url)
        }
      }
    }
  }
}
