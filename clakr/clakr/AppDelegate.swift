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
    // MARK: - Properties

    private var statusBarItem: NSStatusItem?
    private var window: NSWindow?
    private let popover = NSPopover()
    private let menuManager = MenuManager.shared
    private let contentViewViewModel = ContentView.ViewModel()
    private var settingsWindow: NSWindow?
    private let autoClicker = AutoClicker()
    private var aboutWindow: NSWindow?

    // MARK: - Constants

    private enum Constants {
        static let fixedWindowSize = NSSize(width: 320, height: 450)
        static let systemPreferencesURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        static let openSystemPreferencesButtonReturn = NSApplication.ModalResponse.alertFirstButtonReturn
    }

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_: Notification) {
        setupApplication()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods

    private func setupApplication() {
        setupMainMenu()
        setupInitialConfiguration()
        setupKeyboardShortcuts()
        setupObservers()
    }

    private func setupMainMenu() {
        menuManager.setupMainMenu()
        menuManager.aboutMenuActionTarget = self
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .openSettingsShortcut) { [weak self] in
            self?.toggleSettings()
        }
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(toggleMenuBarMode), name: .toggleMenuBarMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupInitialConfiguration() {
        setupWindow()
        configureWindow()
        checkAccessibilityPermissions()
        applyDockIconPolicy()
        if isMenuBarModeEnabled { toggleMenuBarMode() }
        menuManager.setupMainMenu()
        setupSettingsWindow()
        setupKeyboardShortcutListener()
    }

    private func setupWindow() {
        window = NSApplication.shared.windows.first ?? createNewWindow()
        window?.makeKeyAndOrderFront(nil)
    }

    private func createNewWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: Constants.fixedWindowSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        return window
    }

    private func configureWindow() {
        guard let window else { return }
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

    private func setupKeyboardShortcutListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateShortcutStatus), name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateShortcutStatus), name: NSApplication.willResignActiveNotification, object: nil)
    }

    // MARK: - Window Delegate Methods

    func windowWillResize(_: NSWindow, to _: NSSize) -> NSSize {
        Constants.fixedWindowSize
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard let window, !flag else { return false }
        window.makeKeyAndOrderFront(nil)
        return true
    }

    // MARK: - Permissions and Policies

    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        guard !AXIsProcessTrustedWithOptions(options) else { return }

        let alert = NSAlert()
        alert.configureForAccessibilityPermissions()
        if alert.runModal() == Constants.openSystemPreferencesButtonReturn {
            NSWorkspace.shared.open(Constants.systemPreferencesURL)
        }
    }

    private func applyDockIconPolicy() {
        NSApp.setActivationPolicy(UserDefaults.standard.bool(forKey: "hideDockIcon") ? .accessory : .regular)
    }

    // MARK: - Menu Bar Mode

    @objc private func toggleMenuBarMode() {
        guard let window else { return }
        if isMenuBarModeEnabled {
            window.orderOut(nil)
            setupStatusBarItemIfNeeded()
        } else {
            window.makeKeyAndOrderFront(nil)
            removeStatusBarItem()
        }
    }

    private var isMenuBarModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isMenuBarModeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isMenuBarModeEnabled") }
    }

    private func setupStatusBarItemIfNeeded() {
        guard statusBarItem == nil else { return }
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "cursorarrow.click", accessibilityDescription: "Auto Clicker")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        constructMenu()
    }

    private func removeStatusBarItem() {
        if let item = statusBarItem {
            NSStatusBar.system.removeStatusItem(item)
            statusBarItem = nil
        }
    }

    private func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: NSLocalizedString("Open Settings", comment: ""), action: #selector(toggleSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("Quit", comment: ""), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem?.menu = menu
    }

    // MARK: - Actions

    @objc func aboutMenuWindow() {
        settingsWindow?.close()

        if let aboutWin = aboutWindow, aboutWin.isVisible {
            aboutWin.makeKeyAndOrderFront(nil)
        } else {
            createAndShowAboutWindowIfNeeded()
        }

        NSApp.activate(ignoringOtherApps: true)
    }

    private func createAndShowAboutWindowIfNeeded() {
        if aboutWindow == nil {
            let aboutView = AboutMenuBarView()
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            aboutWindow?.center()
            aboutWindow?.setFrameAutosaveName("About")
            aboutWindow?.title = "About Clakr"
            aboutWindow?.contentView = NSHostingView(rootView: aboutView)
            aboutWindow?.titlebarAppearsTransparent = true
            aboutWindow?.isMovableByWindowBackground = true
            aboutWindow?.isOpaque = true
        }

        aboutWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func applicationDidBecomeActive(notification _: NSNotification) {
        menuManager.setupMainMenu()
    }

    @objc private func updateShortcutStatus(notification: Notification) {
        if notification.name == NSApplication.didBecomeActiveNotification {
            KeyboardShortcuts.enable(.openSettingsShortcut)
        } else {
            KeyboardShortcuts.disable(.openSettingsShortcut)
        }
    }

    @objc func toggleSettings() {
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.toggle()
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

// MARK: - Extensions

private extension NSWindow {
    func configureForSettings() {
        title = NSLocalizedString("Settings", comment: "")
        setContentSize(NSSize(width: 480, height: 270))
        styleMask = [.titled, .closable]
        center()
    }

    func toggle() {
        isVisible ? orderOut(nil) : makeKeyAndOrderFront(nil)
    }
}

private extension NSAlert {
    func configureForAccessibilityPermissions() {
        messageText = NSLocalizedString("Accessibility Permission Required", comment: "")
        informativeText = NSLocalizedString("Please grant accessibility permissions for clakr to function properly. This is needed to simulate mouse clicks.", comment: "")
        alertStyle = .critical
        addButton(withTitle: NSLocalizedString("Open System Preferences", comment: ""))
        addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
    }
}
