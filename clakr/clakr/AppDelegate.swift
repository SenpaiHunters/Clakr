//
//  AppDelegate.swift
//  clakr
//
//  Created by Kami on 7/4/2024.
//

import Cocoa
import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  // UI components and managers
  private var statusBarItem: NSStatusItem?
  private var popover = NSPopover()
  private var window: NSWindow?
  private let menuManager = MenuManager()
  private var contentViewViewModel = ContentView.ViewModel()
  private var isTogglingSettings = false

  // Constants used throughout the app delegate
  private enum Constants {
    static let fixedWindowSize = NSSize(width: 320, height: 450)
    static let systemPreferencesURL = URL(
      string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
    static let openSystemPreferencesButtonReturn = NSApplication.ModalResponse
      .alertFirstButtonReturn
  }

  // Called when the application has completed its launch sequence
  func applicationDidFinishLaunching(_ notification: Notification) {
    setup()
    applyDockIconPolicy()
    if isMenuBarModeEnabled {
      toggleMenuBarMode()
    }
    menuManager.setupMainMenu()
    NotificationCenter.default.addObserver(
      self, selector: #selector(toggleMenuBarMode), name: .toggleMenuBarMode, object: nil)
    setupKeyboardShortcutListener()
  }

  // Initial setup for the main window and accessibility permissions
  private func setup() {
    window = NSApplication.shared.windows.first
    configureWindow()
    checkAccessibilityPermissions()
  }

  // Configures the main window's appearance and behavior
  private func configureWindow() {
    guard let window = window else { return }
    window.delegate = self  // Set the AppDelegate as the window's delegate
    // Set up the window's title bar and size constraints
    window.standardWindowButton(.closeButton)?.isEnabled = true
    window.standardWindowButton(.miniaturizeButton)?.isEnabled = true
    window.standardWindowButton(.zoomButton)?.isEnabled = false
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    window.styleMask = [.fullSizeContentView, window.styleMask.subtracting(.resizable)]
    window.setContentSize(Constants.fixedWindowSize)
    window.minSize = Constants.fixedWindowSize
    window.maxSize = Constants.fixedWindowSize
  }

  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    // Return the fixed window size regardless of the frameSize being requested.
    return Constants.fixedWindowSize
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool
  {
    if !flag {
      // If there are no visible windows, bring back the main window
      if let window = window {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
      }
    }
    return true
  }

  // Checks and requests accessibility permissions necessary for the app
  private func checkAccessibilityPermissions() {
    let options =
      [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    if AXIsProcessTrustedWithOptions(options) { return }

    let alert = NSAlert()
    alert.messageText = "Accessibility Permission Required"
    alert.informativeText =
      "Please grant accessibility permissions for clakr to function properly. This is needed to simulate mouse clicks."
    alert.alertStyle = .critical
    alert.addButton(withTitle: "Open System Preferences")
    alert.addButton(withTitle: "Cancel")

    if alert.runModal() == Constants.openSystemPreferencesButtonReturn {
      NSWorkspace.shared.open(Constants.systemPreferencesURL)
    }
  }

  // Handles the application's Dock icon visibility based on user preference
  private func applyDockIconPolicy() {
    let shouldHideDockIcon = UserDefaults.standard.bool(forKey: "hideDockIcon")
    NSApp.setActivationPolicy(shouldHideDockIcon ? .accessory : .regular)
  }

  // Sets up a listener for keyboard shortcuts
  private func setupKeyboardShortcutListener() {
    let notificationCenter = NotificationCenter.default

    notificationCenter.addObserver(
      self,
      selector: #selector(updateShortcutStatus),
      name: NSApplication.didBecomeActiveNotification,
      object: nil
    )

    notificationCenter.addObserver(
      self,
      selector: #selector(updateShortcutStatus),
      name: NSApplication.willResignActiveNotification,
      object: nil
    )

    KeyboardShortcuts.onKeyUp(for: .openSettingsShortcut) { [weak self] in
      self?.toggleSettings()
    }
  }

  // Don't forget to remove observers when they are no longer needed
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // Helper method to enable/disable the shortcut based on application's active status
  @objc private func updateShortcutStatus(notification: Notification) {
    if notification.name == NSApplication.didBecomeActiveNotification {
      KeyboardShortcuts.enable(.openSettingsShortcut)
    } else if notification.name == NSApplication.willResignActiveNotification {
      KeyboardShortcuts.disable(.openSettingsShortcut)
    }
  }

  // Toggles between the menu bar mode and windowed mode
  @objc private func toggleMenuBarMode() {
    guard let window = window else {
      NSLog("Window is nil, cannot toggle menu bar mode.")
      return
    }
    // Switch between showing the status bar item and the main window
    if isMenuBarModeEnabled {
      window.orderOut(nil)
      setupStatusBarItem()
    } else {
      statusBarItem?.isVisible = false
      window.makeKeyAndOrderFront(nil)
    }
  }

  // UserDefaults-backed property to toggle menu bar mode
  private var isMenuBarModeEnabled: Bool {
    get {
      UserDefaults.standard.bool(forKey: "isMenuBarModeEnabled")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "isMenuBarModeEnabled")
    }
  }

  // Toggles the settings view
  @objc func toggleSettings() {
    isTogglingSettings = true
    showSettings.toggle()  // Toggle the boolean value to show or hide settings
    if showSettings {
      // Activate the app and bring the settings window to the front
      if let window = window {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
      }
    }
    // Notify any observers that the settings visibility has changed
    NotificationCenter.default.post(name: .showSettings, object: nil)
    isTogglingSettings = false
  }

  // Property to manage the visibility of the settings view
  private var showSettings: Bool {
    get {
      contentViewViewModel.showingSettings
    }
    set {
      contentViewViewModel.showingSettings = newValue
    }
  }

  // Sets up the status bar item with an icon and menu
  private func setupStatusBarItem() {
    statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusBarItem?.button {
      // Configure the button appearance and action
      button.image = NSImage(
        systemSymbolName: "cursorarrow.click", accessibilityDescription: "Auto Clicker")
      button.action = #selector(togglePopover(_:))
      button.target = self
    }
    // Construct the menu for the status bar item
    constructMenu()
  }

  // Constructs the menu to be displayed from the status bar item
  private func constructMenu() {
    let menu = NSMenu()
    // Add items to the menu for settings and quitting the app
    menu.addItem(
      NSMenuItem(title: "Open Settings", action: #selector(toggleSettings), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(
      NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    statusBarItem?.menu = menu
  }

  // Toggles the popover from the status bar item
  @objc private func togglePopover(_ sender: AnyObject?) {
    if popover.isShown {
      popover.performClose(sender)
    } else {
      // If the popover isn't shown, bring the main window to the front
      if let window = window {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
      } else {
        toggleSettings()
      }
    }
  }
}
