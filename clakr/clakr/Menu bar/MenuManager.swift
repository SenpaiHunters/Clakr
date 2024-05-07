//
//  MenuManager.swift
//  clakr
//
//  Created by Kami on 8/4/2024.
//

import Cocoa
import Sparkle
import SwiftUI

class MenuManager: NSObject {
  static let shared = MenuManager()
  var updaterController: SPUStandardUpdaterController?
  weak var aboutMenuActionTarget: AnyObject?

  struct Constants {
    static let clakrHelpURL = "https://github.com/senpaihunters/clakr"
    static let clakrFeedbackURL = "https://github.com/SenpaiHunters/Clakr/issues/new/choose"
  }

  private func createCheckForUpdatesMenuItem() -> NSMenuItem {
    let menuItem = NSMenuItem(
      title: NSLocalizedString(
        "Check for Updates...", comment: "Menu item title for checking updates"),
      action: #selector(checkForUpdates), keyEquivalent: "")
    menuItem.target = self
    return menuItem
  }

  func setupWithUpdaterController(_ updaterController: SPUStandardUpdaterController) {
    self.updaterController = updaterController
  }

  @objc func checkForUpdates() {
    print("Check for updates triggered")
    updaterController?.checkForUpdates(nil)
  }

  func setupMainMenu() {
    let mainMenu = NSMenu()
    mainMenu.addItem(
      createMenuItem(
        title: NSLocalizedString("Application", comment: "Main menu Application title"),
        action: nil, keyEquivalent: "", submenu: createAppMenu()))
    mainMenu.addItem(
      createMenuItem(
        title: NSLocalizedString("Help", comment: "Main menu Help title"), action: nil,
        keyEquivalent: "", submenu: createHelpMenu()))
    NSApp.mainMenu = mainMenu
    mainMenu.delegate = self
  }

  protocol MenuActionsDelegate: AnyObject {
    func showAboutWindow()
  }

  private func createAppMenu() -> NSMenu {
    let appMenu = NSMenu(title: NSLocalizedString("Application", comment: "App menu title"))

    let aboutMenuItem = NSMenuItem(
      title: NSLocalizedString("About Clakr", comment: "App menu item for About Clakr"),
      action: #selector(AppDelegate.aboutMenuWindow), keyEquivalent: "")
    aboutMenuItem.target = aboutMenuActionTarget

    appMenu.addItem(aboutMenuItem)

    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(createServicesMenuItem())
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(
      withTitle: NSLocalizedString("Settings", comment: "App menu item for Settings"),
      action: #selector(AppDelegate.toggleSettings), keyEquivalent: ",")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(
      NSMenuItem(
        title: NSLocalizedString("Quit Clakr", comment: "App menu item for Quit Clakr"),
        action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    return appMenu
  }

  private func createHelpMenu() -> NSMenu {
    let helpMenu = NSMenu(title: NSLocalizedString("Help", comment: "Help menu title"))
    helpMenu.addItem(
      createMenuItem(
        title: NSLocalizedString("Clakr Help", comment: "Help menu item for Clakr Help"),
        action: #selector(showHelp), keyEquivalent: "?"))
    helpMenu.addItem(NSMenuItem.separator())
    helpMenu.addItem(
      createMenuItem(
        title: NSLocalizedString(
          "Provide Feedback", comment: "Help menu item for Provide Feedback"),
        action: #selector(provideFeedback), keyEquivalent: ""))
    helpMenu.addItem(NSMenuItem.separator())
    helpMenu.addItem(
      createMenuItem(
        title: NSLocalizedString("Debug", comment: "Help menu item for Debug"),
        action: #selector(debugApplication), keyEquivalent: "d"))
    return helpMenu
  }

  private func createServicesMenuItem() -> NSMenuItem {
    let servicesMenu = NSMenu(title: NSLocalizedString("Services", comment: "Services menu title"))
    NSApp.servicesMenu = servicesMenu
    return createMenuItem(
      title: NSLocalizedString("Services", comment: "Services menu item title"), action: nil,
      keyEquivalent: "", submenu: servicesMenu)
  }

  private func createMenuItem(
    title: String, action: Selector?, keyEquivalent: String, submenu: NSMenu? = nil
  ) -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
    menuItem.submenu = submenu
    menuItem.target = self
    return menuItem
  }

  @objc func showHelp() {
    openURL(Constants.clakrHelpURL)
  }

  @objc func provideFeedback() {
    openURL(Constants.clakrFeedbackURL)
  }

  private func openURL(_ urlString: String) {
    guard let url = URL(string: urlString) else {
      // Handle invalid URL
      return
    }
    NSWorkspace.shared.open(url)
  }

  @objc func openSettings() {
    NotificationCenter.default.post(name: .showSettings, object: nil)
  }

  @objc func debugApplication() {
    let appBlacklistString = UserDefaults.standard.string(forKey: "appBlacklistString") ?? ""
    let blacklist: [BlacklistedApp] = Array.from(jsonString: appBlacklistString) ?? []
    let blacklistContents = blacklist.map { "\($0.name) (\($0.bundleID))" }.joined(separator: ", ")

    let debugInfo = DebugInformation(
      hasAccessibilityPermissions: AXIsProcessTrusted(),
      accessibilityEnabled: NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast,
      appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
      buildVersion: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
      osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
      mainRunLoopActive: RunLoop.current.isEqual(RunLoop.main),
      blacklistContents: blacklistContents,
      blacklistCount: blacklist.count
    )

    let message = debugInfo.formattedMessage()
    let alert = NSAlert()
    alert.messageText = NSLocalizedString(
      "Debug Information", comment: "Title for debug information alert")
    alert.informativeText = message
    alert.alertStyle = .informational
    let buttonTitles = [
      NSLocalizedString("OK", comment: "OK button"),
      NSLocalizedString("Copy Debug Info", comment: "Copy debug information to clipboard"),
      NSLocalizedString(
        "Reset Accessibility Permissions", comment: "Reset accessibility permissions"),
      NSLocalizedString("Factory Reset", comment: "Factory reset the application"),
    ]
    buttonTitles.forEach { alert.addButton(withTitle: $0) }

    let response = alert.runModal()
    handleAlertResponse(response, debugInfo: message)
  }

  private func handleAlertResponse(_ response: NSApplication.ModalResponse, debugInfo: String) {
    switch response {
    case .alertFirstButtonReturn:  // OK button
      // Do nothing
      break
    case .alertSecondButtonReturn:  // Copy Debug Info
      copyDebugInfoToClipboard(debugInfo: debugInfo)
      break
    case .alertThirdButtonReturn:  // Reset Accessibility Permissions
      openSystemPreferencesAccessibility()
      break
    case NSApplication.ModalResponse(rawValue: 1003):  // Factory Reset
      confirmAndPerformFactoryReset()
      break
    default:
      print("Unhandled alert response: \(response.rawValue). Please report this issue.")
      break
    }
  }

  private func copyDebugInfoToClipboard(debugInfo: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(debugInfo, forType: .string)
  }

  private func openSystemPreferencesAccessibility() {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    else { return }
    NSWorkspace.shared.open(url)
  }

  private func confirmAndPerformFactoryReset() {
    let confirmAlert = NSAlert()
    confirmAlert.messageText = NSLocalizedString(
      "Confirm Factory Reset", comment: "Title for factory reset confirmation alert")
    confirmAlert.informativeText = NSLocalizedString(
      "Are you sure you want to reset all settings to their default values? This action cannot be undone.",
      comment: "Factory reset confirmation message")
    confirmAlert.alertStyle = .warning
    confirmAlert.addButton(withTitle: NSLocalizedString("Reset", comment: "Reset button"))
    confirmAlert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel button"))

    let response = confirmAlert.runModal()
    print("Factory reset confirmation alert response: \(response)")

    if response == .alertFirstButtonReturn {
      // User confirmed factory reset. Clearing user defaults and restarting app.
      clearUserDefaults()
      restartApp()
    } else {
      print("Factory reset cancelled by user.")
    }
  }

  private struct DebugInformation {
    let hasAccessibilityPermissions: Bool
    let accessibilityEnabled: Bool
    let appVersion: String
    let buildVersion: String
    let osVersion: String
    let mainRunLoopActive: Bool
    let blacklistContents: String
    let blacklistCount: Int

    func formattedMessage() -> String {
      let debugInfoTitle = NSLocalizedString("Debug Information", comment: "")
      let accessibilityPermissionsTitle = NSLocalizedString(
        "Accessibility Permissions", comment: "")
      let accessibilityPermissionsValue = NSLocalizedString(
        hasAccessibilityPermissions ? "Granted" : "Denied", comment: "")
      let accessibilityEnabledTitle = NSLocalizedString("Accessibility Enabled", comment: "")
      let accessibilityEnabledValue = NSLocalizedString(
        accessibilityEnabled ? "Yes" : "No", comment: "")
      let appVersionTitle = NSLocalizedString("App Version", comment: "")
      let buildVersionTitle = NSLocalizedString("Build Version", comment: "")
      let macOSVersionTitle = NSLocalizedString("macOS Version", comment: "")
      let mainRunLoopActiveTitle = NSLocalizedString("Main Run Loop Active", comment: "")
      let mainRunLoopActiveValue = NSLocalizedString(mainRunLoopActive ? "Yes" : "No", comment: "")
      let blacklistCountTitle = NSLocalizedString("Blacklist Count", comment: "")
      let blacklistedApplicationsTitle = NSLocalizedString("Blacklisted Applications", comment: "")

      return """
        \(debugInfoTitle):
        \(accessibilityPermissionsTitle): \(accessibilityPermissionsValue)
        \(accessibilityEnabledTitle): \(accessibilityEnabledValue)
        \(appVersionTitle): \(appVersion)
        \(buildVersionTitle): \(buildVersion)
        \(macOSVersionTitle): \(osVersion)
        \(mainRunLoopActiveTitle): \(mainRunLoopActiveValue)
        \(blacklistCountTitle): \(blacklistCount)
        \(blacklistedApplicationsTitle): \(blacklistContents)
        """
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

    // Delay termination to give the new instance time to start.
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      NSApp.terminate(nil)
    }
  }

  /**
  * Old version, although it had issues on intel systems, above
  * is untested, so this code is staying here for now
  * private func restartApp() {
  * guard let bundleID = Bundle.main.bundleIdentifier else { return }
  * let task = Process()
  * task.launchPath = "/usr/bin/open"
  * task.arguments = ["-b", bundleID]
  * task.launch()
  *
  * NSApp.terminate(nil)
  * }
  */
}
