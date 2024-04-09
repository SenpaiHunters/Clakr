//
//  MenuManager.swift
//  clakr
//
//  Created by Kami on 8/4/2024.
//

import Cocoa
import SwiftUI

class MenuManager: NSObject {
  static let shared = MenuManager()
  
  struct Constants {
    static let clakrHelpURL = "https://github.com/senpaihunters/clakr"
    static let clakrFeedbackURL = "https://github.com/SenpaiHunters/Clakr/issues/new/choose"
  }

  func setupMainMenu() {
    let mainMenu = NSMenu()
    mainMenu.addItem(createMenuItem(title: "Application", action: nil, keyEquivalent: "", submenu: createAppMenu()))
    mainMenu.addItem(createMenuItem(title: "Help", action: nil, keyEquivalent: "", submenu: createHelpMenu()))
    NSApp.mainMenu = mainMenu
    mainMenu.delegate = self
  }

  private func createAppMenu() -> NSMenu {
    let appMenu = NSMenu(title: "Application")
    appMenu.addItem(NSMenuItem(title: "About Clakr", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(createServicesMenuItem())
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Settings", action: #selector(AppDelegate.toggleSettings), keyEquivalent: ",")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(NSMenuItem(title: "Quit Clakr", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    return appMenu
  }

  private func createHelpMenu() -> NSMenu {
    let helpMenu = NSMenu(title: "Help")
    helpMenu.addItem(createMenuItem(title: "Clakr Help", action: #selector(showHelp), keyEquivalent: "?"))
    helpMenu.addItem(NSMenuItem.separator())
    helpMenu.addItem(createMenuItem(title: "Provide Feedback", action: #selector(provideFeedback), keyEquivalent: ""))
    return helpMenu
  }

  private func createServicesMenuItem() -> NSMenuItem {
    let servicesMenu = NSMenu(title: "Services")
    NSApp.servicesMenu = servicesMenu
    return createMenuItem(title: "Services", action: nil, keyEquivalent: "", submenu: servicesMenu)
  }

  private func createMenuItem(title: String, action: Selector?, keyEquivalent: String, submenu: NSMenu? = nil) -> NSMenuItem {
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
}
