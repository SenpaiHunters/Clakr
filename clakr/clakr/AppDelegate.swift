//
//  AppDelegate.swift
//  clakr
//
//  Created by Kami on 7/4/2024.
//

import Cocoa
import KeyboardShortcuts
import Sparkle
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  private var statusBarItem: NSStatusItem?
  private var window: NSWindow?
  private var popover = NSPopover()
  private let menuManager = MenuManager()
  private var contentViewViewModel = ContentView.ViewModel()
  private var settingsWindow: NSWindow?
  private var autoClicker = AutoClicker()
  private var aboutWindow: NSWindow?

  private enum Constants {
    static let fixedWindowSize = NSSize(width: 320, height: 450)
    static let systemPreferencesURL = URL(
      string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
    static let openSystemPreferencesButtonReturn = NSApplication.ModalResponse
      .alertFirstButtonReturn
  }

@objc func aboutMenuWindow() {
    // Check if settingsWindow is visible and close it if necessary
    if settingsWindow?.isVisible == true {
        settingsWindow?.close()
    }

    // Safely unwrap aboutWindow to check if it's already visible
    if let aboutWin = aboutWindow, aboutWin.isVisible {
        aboutWin.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        return
    }

    // Only create a new aboutWindow if it does not exist
    if aboutWindow == nil {
        let aboutView = AboutMenuBarView()
        aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false)
        aboutWindow?.center()
        aboutWindow?.setFrameAutosaveName("About")
        aboutWindow?.title = "About Clakr"
        aboutWindow?.contentView = NSHostingView(rootView: aboutView)
        aboutWindow?.titlebarAppearsTransparent = true
        aboutWindow?.isMovableByWindowBackground = true
        aboutWindow?.isOpaque = true
    }

    // Safely attempt to make the aboutWindow key and order front
    aboutWindow?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
}

func applicationDidFinishLaunching(_ notification: Notification) {
    setupMainMenu()
    setupUpdaterController()
    setupInitialConfiguration()
    setupKeyboardShortcuts()
    setupObservers()
}

private func setupMainMenu() {
    MenuManager.shared.setupMainMenu()
    // Ensure the main menu is empty before setting it up to avoid duplicates
    NSApp.mainMenu = NSMenu()

    // Dynamically add the "About Clakr" menu item if it doesn't already exist
    /// I've had some issues with the menu not showing if all windows are closed
    /// and reopened, this seems to fix it
    if let appMenu = NSApp.mainMenu?.item(withTitle: "Application"),
       appMenu.submenu?.items.contains(where: { $0.action == #selector(aboutMenuWindow) }) == false {
        let aboutMenuItem = NSMenuItem(title: "About Clakr", action: #selector(aboutMenuWindow), keyEquivalent: "")
        aboutMenuItem.target = self
        appMenu.submenu?.addItem(aboutMenuItem)
    }
}

private func setupUpdaterController() {
    let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    MenuManager.shared.setupWithUpdaterController(updaterController)
}

private func setupKeyboardShortcuts() {
    KeyboardShortcuts.onKeyUp(for: .openSettingsShortcut) { [weak self] in self?.toggleSettings() }
}

private func setupObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(toggleMenuBarMode), name: .toggleMenuBarMode, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
}

@objc private func applicationDidBecomeActive(notification: NSNotification) {
    // Reapply menu setup
    MenuManager.shared.setupMainMenu()
}

  private func setupInitialConfiguration() {
    window = NSApplication.shared.windows.first
    if window == nil {
      // handle nil by making a new window....
      window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 320, height: 450),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
      window?.center()
      window?.makeKeyAndOrderFront(nil)
    }
    configureWindow()
    checkAccessibilityPermissions()
    applyDockIconPolicy()
    if isMenuBarModeEnabled { toggleMenuBarMode() }
    menuManager.setupMainMenu()
    setupSettingsWindow()
    setupKeyboardShortcutListener()
  }

  private func configureWindow() {
    guard let window = window else { return }
    window.delegate = self
    window.standardWindowButton(.closeButton)?.isEnabled = true
    window.standardWindowButton(.miniaturizeButton)?.isEnabled = true
    window.standardWindowButton(.zoomButton)?.isEnabled = false
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    window.styleMask.insert(.fullSizeContentView)
    window.styleMask.remove(.resizable)
    window.setContentSize(Constants.fixedWindowSize)
    window.minSize = Constants.fixedWindowSize
    window.maxSize = Constants.fixedWindowSize
  }

  private func setupSettingsWindow() {
    let settingsView = SettingsView(autoClicker: autoClicker)
    settingsWindow = NSWindow(contentViewController: NSHostingController(rootView: settingsView))
    settingsWindow?.configureForSettings()
  }

  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    return Constants.fixedWindowSize
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    guard let window = window else { return false }
    if !flag {
      window.makeKeyAndOrderFront(nil)
      return true
    }
    return false
  }

  private func checkAccessibilityPermissions() {
    let options =
      [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    guard !AXIsProcessTrustedWithOptions(options) else { return }

    let alert = NSAlert()
    alert.configureForAccessibilityPermissions()
    if alert.runModal() == Constants.openSystemPreferencesButtonReturn {
      NSWorkspace.shared.open(Constants.systemPreferencesURL)
    }
  }

  private func applyDockIconPolicy() {
    NSApp.setActivationPolicy(
      UserDefaults.standard.bool(forKey: "hideDockIcon") ? .accessory : .regular)
  }

  private func setupKeyboardShortcutListener() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(updateShortcutStatus),
      name: NSApplication.didBecomeActiveNotification, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(updateShortcutStatus),
      name: NSApplication.willResignActiveNotification, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func updateShortcutStatus(notification: Notification) {
    if notification.name == NSApplication.didBecomeActiveNotification {
      KeyboardShortcuts.enable(.openSettingsShortcut)
    } else if notification.name == NSApplication.willResignActiveNotification {
      KeyboardShortcuts.disable(.openSettingsShortcut)
    }
  }

  @objc private func toggleMenuBarMode() {
    guard let window = window else { return }
    if isMenuBarModeEnabled {
      window.orderOut(nil)
      if statusBarItem == nil {
        setupStatusBarItem()
      }
    } else {
      window.makeKeyAndOrderFront(nil)
      if let item = statusBarItem {
        NSStatusBar.system.removeStatusItem(item)
        statusBarItem = nil
      }
    }
  }

  private var isMenuBarModeEnabled: Bool {
    get { UserDefaults.standard.bool(forKey: "isMenuBarModeEnabled") }
    set { UserDefaults.standard.set(newValue, forKey: "isMenuBarModeEnabled") }
  }

  @objc func toggleSettings() {
    NSApp.activate(ignoringOtherApps: true)
    if let settingsWindow = settingsWindow {
      settingsWindow.isVisible
        ? settingsWindow.orderOut(nil) : settingsWindow.makeKeyAndOrderFront(nil)
    }
  }

  private func setupStatusBarItem() {
    statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusBarItem?.button {
      button.image = NSImage(
        systemSymbolName: "cursorarrow.click", accessibilityDescription: "Auto Clicker")
      button.action = #selector(togglePopover(_:))
      button.target = self
    }
    constructMenu()
  }

  private func constructMenu() {
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: NSLocalizedString("Open Settings", comment: ""), action: #selector(toggleSettings), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: NSLocalizedString("Quit", comment: ""), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    statusBarItem?.menu = menu
  }

  @objc private func togglePopover(_ sender: AnyObject?) {
    if popover.isShown {
      popover.performClose(sender)
    } else {
      window?.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }
  }
}

extension NSWindow {
  fileprivate func configureForSettings() {
    title = NSLocalizedString("Settings", comment: "")
    setContentSize(NSSize(width: 480, height: 270))
    styleMask = [.titled, .closable]
    center()
  }
}

extension NSAlert {
  fileprivate func configureForAccessibilityPermissions() {
    messageText = NSLocalizedString("Accessibility Permission Required", comment: "")
    informativeText = NSLocalizedString("Please grant accessibility permissions for clakr to function properly. This is needed to simulate mouse clicks.", comment: "")
    alertStyle = .critical
    addButton(withTitle: NSLocalizedString("Open System Preferences", comment: ""))
    addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
  }
}
