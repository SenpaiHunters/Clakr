//
//  MenuManager.swift
//  clakr
//
//  Created by Kami on 8/4/2024.
//

import Cocoa
import SwiftUI

final class MenuManager: NSObject {
    static let shared = MenuManager()

    weak var aboutMenuActionTarget: AnyObject?

    private enum Constants {
        static let clakrHelpURL = "https://github.com/senpaihunters/clakr"
        static let clakrFeedbackURL = "https://github.com/SenpaiHunters/Clakr/issues/new/choose"
        static let accessibilityPreferencesURL = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    }

    @objc func openSettings() {
        NotificationCenter.default.post(name: .showSettings, object: nil)
    }

    @objc func quitApplication() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Menu Setup

    func setupMainMenu() {
        let mainMenu = NSMenu()
        mainMenu.addItem(createMenuItem(title: "Application", submenu: createAppMenu()))
        mainMenu.addItem(createMenuItem(title: "Help", submenu: createHelpMenu()))
        NSApp.mainMenu = mainMenu
    }

    private func createAppMenu() -> NSMenu {
        let appMenu = NSMenu(title: "Application")
        appMenu.items = [
            createMenuItem(title: "About Clakr", action: #selector(AppDelegate.aboutMenuWindow), target: NSApp.delegate),
            .separator(),
            createServicesMenuItem(),
            .separator(),
            createMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","),
            .separator(),
            createMenuItem(title: "Quit Clakr", action: #selector(quitApplication), keyEquivalent: "q")
        ]
        return appMenu
    }

    private func createHelpMenu() -> NSMenu {
        let helpMenu = NSMenu(title: "Help")
        helpMenu.items = [
            createMenuItem(title: "Clakr Help", action: #selector(showHelp), keyEquivalent: "?"),
            .separator(),
            createMenuItem(title: "Provide Feedback", action: #selector(provideFeedback)),
            .separator(),
            createMenuItem(title: "Debug", action: #selector(debugApplication), keyEquivalent: "d")
        ]
        return helpMenu
    }

    // MARK: - Menu Item Creation

    private func createMenuItem(title: String, action: Selector? = nil, keyEquivalent: String = "", submenu: NSMenu? = nil, target: AnyObject? = nil) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        menuItem.submenu = submenu
        menuItem.target = target ?? self
        return menuItem
    }

    private func createServicesMenuItem() -> NSMenuItem {
        let servicesMenu = NSMenu(title: "Services")
        NSApp.servicesMenu = servicesMenu
        return createMenuItem(title: "Services", submenu: servicesMenu)
    }

    // MARK: - Actions

    @objc private func showHelp() {
        openURL(Constants.clakrHelpURL)
    }

    @objc private func provideFeedback() {
        openURL(Constants.clakrFeedbackURL)
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc func debugApplication() {
        let debugInfo = DebugInformation.current()
        let alert = createDebugAlert(with: debugInfo)
        let response = alert.runModal()
        handleDebugAlertResponse(response, debugInfo: debugInfo.formattedMessage())
    }

    // MARK: - Debug Helpers

    private func createDebugAlert(with debugInfo: DebugInformation) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = "Debug Information"
        alert.informativeText = debugInfo.formattedMessage()
        alert.alertStyle = .informational
        ["OK", "Copy Debug Info", "Reset Accessibility Permissions", "Factory Reset"].forEach { alert.addButton(withTitle: $0) }
        return alert
    }

    private func handleDebugAlertResponse(_ response: NSApplication.ModalResponse, debugInfo: String) {
        switch response {
        case .alertSecondButtonReturn:
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(debugInfo, forType: .string)
        case .alertThirdButtonReturn:
            openSystemPreferencesAccessibility()
        case NSApplication.ModalResponse(rawValue: 1003):
            confirmAndPerformFactoryReset()
        default:
            break
        }
    }

    private func openSystemPreferencesAccessibility() {
        guard let url = URL(string: Constants.accessibilityPreferencesURL) else { return }
        NSWorkspace.shared.open(url)
    }

    private func confirmAndPerformFactoryReset() {
        let confirmAlert = NSAlert()
        confirmAlert.messageText = "Confirm Factory Reset"
        confirmAlert.informativeText = "Are you sure you want to reset all settings to their default values? This action cannot be undone."
        confirmAlert.alertStyle = .warning
        confirmAlert.addButton(withTitle: "Reset")
        confirmAlert.addButton(withTitle: "Cancel")

        if confirmAlert.runModal() == .alertFirstButtonReturn {
            clearUserDefaults()
            restartApp()
        }
    }

    private func clearUserDefaults() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
    }

    private func restartApp() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-b", bundleID]
        task.launch()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NSApp.terminate(nil)
        }
    }
}

// MARK: - DebugInformation

private struct DebugInformation {
    let hasAccessibilityPermissions: Bool
    let accessibilityEnabled: Bool
    let appVersion: String
    let buildVersion: String
    let osVersion: String
    let mainRunLoopActive: Bool
    let blacklistContents: String
    let blacklistCount: Int

    static func current() -> DebugInformation {
        let appBlacklistString = UserDefaults.standard.string(forKey: "appBlacklistString") ?? ""
        let blacklist: [BlacklistedApp] = Array.from(jsonString: appBlacklistString) ?? []
        let blacklistContents = blacklist.map { "\($0.name) (\($0.bundleID))" }.joined(separator: ", ")

        return DebugInformation(
            hasAccessibilityPermissions: AXIsProcessTrusted(),
            accessibilityEnabled: NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            buildVersion: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            mainRunLoopActive: RunLoop.current.isEqual(RunLoop.main),
            blacklistContents: blacklistContents,
            blacklistCount: blacklist.count
        )
    }

    func formattedMessage() -> String {
        """
        Debug Information:
        Accessibility Permissions: \(hasAccessibilityPermissions ? "Granted" : "Denied")
        Accessibility Enabled: \(accessibilityEnabled ? "Yes" : "No")
        App Version: \(appVersion)
        Build Version: \(buildVersion)
        macOS Version: \(osVersion)
        Main Run Loop Active: \(mainRunLoopActive ? "Yes" : "No")
        Blacklist Count: \(blacklistCount)
        Blacklisted Applications: \(blacklistContents)
        """
    }
}
