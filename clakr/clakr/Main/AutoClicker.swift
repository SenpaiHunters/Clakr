//
//  AutoClicker.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import Cocoa
import Foundation
import KeyboardShortcuts

class AutoClicker: ObservableObject {
  @Published var playSoundEffects: Bool = UserDefaults.standard.bool(forKey: "playSoundEffects")
  @Published var selectedSoundName: String =
    UserDefaults.standard.string(forKey: "selectedSoundName") ?? NSSound.systemSounds.first ?? ""
  @Published var isClicking = false
  private static let timerQueue = DispatchQueue(label: "com.clakr.autoclicker.timer", qos: .utility)
  private var clickTimer: DispatchSourceTimer?
  private var lastMoved = Date()
  private var mouseMoveMonitor: Any?
  private var rate: TimeInterval = 1.0
  private var stationarySeconds: TimeInterval = 3
  private let eventSource = CGEventSource(stateID: .hidSystemState)
  private var screenHeight: CGFloat = NSScreen.main?.frame.height ?? 500  // Ensure there is at least a frame
  private var mouseDownEvent: CGEvent?
  private var mouseUpEvent: CGEvent?
  private var shouldStopClicking = false
  private var appBlacklist: [String: BlacklistedApp]?

  init() {
    setupKeyboardShortcutListener()
    loadPreferences()
    loadBlacklist()
  }

  private func loadBlacklist() {
    let appBlacklistString = UserDefaults.standard.string(forKey: "appBlacklistString") ?? ""
    if let blacklistArray = Array<BlacklistedApp>.from(jsonString: appBlacklistString) {
      self.appBlacklist = Dictionary(uniqueKeysWithValues: blacklistArray.map { ($0.bundleID, $0) })
    } else {
      print("Failed to decode app blacklist from UserDefaults. Using default non-empty dictionary.")
      // If empty, create a new one as a backup
      self.appBlacklist = [
        "com.kami.clakr": BlacklistedApp(
          name: "clakr", bundleID: "com.kami.clakr")
      ]
    }
  }

  func isCurrentAppBlacklisted() -> Bool {
    guard let appBlacklist = self.appBlacklist else {
      print("Blacklist is not loaded.")
      return false
    }

    guard let activeApp = NSWorkspace.shared.frontmostApplication,
      let activeAppBundleID = activeApp.bundleIdentifier
    else {
      print("Failed to retrieve active application details.")
      return false
    }

    return appBlacklist[activeAppBundleID] != nil
  }

  struct AutoClickerPreferences {
    var clicksPerSecond: Double
    var startAfterSeconds: TimeInterval
    var stopAfterSeconds: TimeInterval
    var stationaryForSeconds: TimeInterval
  }

  private func loadPreferences() {
    let defaults = UserDefaults.standard
    let keys = ["clicksPerSecond", "startAfterSeconds", "stopAfterSeconds", "stationaryForSeconds"]
    let defaultValues = [1000.0, 2.0, 15.0, 3.0]
    let defaultsToRegister = Dictionary(uniqueKeysWithValues: zip(keys, defaultValues))

    for (key, defaultValue) in defaultsToRegister {
      if defaults.object(forKey: key) == nil {
        defaults.set(defaultValue, forKey: key)
      }
    }

    let preferences = AutoClickerPreferences(
      clicksPerSecond: defaults.double(forKey: "clicksPerSecond"),
      startAfterSeconds: defaults.double(forKey: "startAfterSeconds"),
      stopAfterSeconds: defaults.double(forKey: "stopAfterSeconds"),
      stationaryForSeconds: defaults.double(forKey: "stationaryForSeconds")
    )
    self.rate = 1.0 / preferences.clicksPerSecond
    self.stationarySeconds = preferences.stationaryForSeconds
  }

  private func setupKeyboardShortcutListener() {
    KeyboardShortcuts.onKeyUp(for: .toggleAutoClicker) { [weak self] in
      self?.toggleClicking()
    }
  }

  func toggleClicking() {
    if isCurrentAppBlacklisted() {
      print("Active application is blacklisted. Auto-clicker will not be toggled.")
      return
    }
    isClicking.toggle()

    if playSoundEffects {
      playSound(name: selectedSoundName)
    }

    if isClicking {
      startClicking()
    } else {
      stopClicking()
    }
  }

  func startClicking() {
    let defaults = UserDefaults.standard
    let preferences = fetchUserPreferences(
      defaults: defaults,
      keys: ["clicksPerSecond", "startAfterSeconds", "stopAfterSeconds", "stationaryForSeconds"],
      defaultValues: [1.0, 0.1, 0.1, 0.1]
    )

    self.rate = 1.0 / preferences[0]
    self.stationarySeconds = preferences[3]
    self.shouldStopClicking = false

    DispatchQueue.main.asyncAfter(deadline: .now() + preferences[1]) { [weak self] in
      guard let self = self, !self.shouldStopClicking else { return }
      self.isClicking = true
      self.startTimer()

      if preferences[2] > 0 {
        let totalDelay = preferences[1] + preferences[2]
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
          guard !self.shouldStopClicking else { return }
          self.stopClicking()
        }
      }
    }

    if mouseMoveMonitor == nil {
      mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) {
        [weak self] event in
        self?.mouseDidMove(event: event)
      }
    }
  }

  private func fetchUserPreferences(defaults: UserDefaults, keys: [String], defaultValues: [Double])
    -> [Double]
  {
    return keys.map { key in
      let index = keys.firstIndex(of: key)!
      return defaults.object(forKey: key) != nil
        ? defaults.double(forKey: key) : defaultValues[index]
    }
  }

  private func mouseDidMove(event: NSEvent) {
    lastMoved = Date()
  }

  func stopClicking() {
    self.isClicking = false
    self.shouldStopClicking = true

    DispatchQueue.main.async {
      self.clickTimer?.cancel()
      self.clickTimer = nil

      if let monitor = self.mouseMoveMonitor {
        NSEvent.removeMonitor(monitor)
        self.mouseMoveMonitor = nil
      }
    }
  }

  private func startTimer() {
    clickTimer?.cancel()

    clickTimer = DispatchSource.makeTimerSource(queue: AutoClicker.timerQueue)
    clickTimer?.schedule(deadline: .now(), repeating: rate, leeway: .nanoseconds(1))
    clickTimer?.setEventHandler { [weak self] in
      self?.click()
    }
    clickTimer?.resume()
  }

  private func click() {
    guard isClicking, -lastMoved.timeIntervalSinceNow >= stationarySeconds else {
      return
    }

    let mouseLocation = NSEvent.mouseLocation
    let newPoint = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)

    // Check if mouseDownEvent and mouseUpEvent are nil before creating new instances
    if mouseDownEvent == nil {
      mouseDownEvent = createMouseEvent(type: .leftMouseDown, point: newPoint)
    } else {
      // Update the location of the existing mouseDownEvent
      mouseDownEvent?.location = newPoint
    }

    if mouseUpEvent == nil {
      mouseUpEvent = createMouseEvent(type: .leftMouseUp, point: newPoint)
    } else {
      // Update the location of the existing mouseUpEvent
      mouseUpEvent?.location = newPoint
    }

    mouseDownEvent?.post(tap: .cghidEventTap)
    mouseUpEvent?.post(tap: .cghidEventTap)
  }

  private func createMouseEvent(type: CGEventType, point: CGPoint) -> CGEvent? {
    guard
      let event = CGEvent(
        mouseEventSource: eventSource, mouseType: type, mouseCursorPosition: point,
        mouseButton: .left)
    else {
      print("Failed to create CGEvent for mouse event of type \(type.rawValue)")
      return nil
    }
    return event
  }

  func playSound(name: String) {
    let fileManager = FileManager.default
    var soundURL: URL?

    // Check for system sounds
    if NSSound.systemSounds.contains(name) {
      let systemSoundsPath = "/System/Library/Sounds"
      let potentialSoundURL = URL(fileURLWithPath: systemSoundsPath).appendingPathComponent(name)
        .appendingPathExtension("aiff")
      if fileManager.fileExists(atPath: potentialSoundURL.path) {
        soundURL = potentialSoundURL
      }
    }
    // Existing checks for custom and imported sounds remain unchanged
    else if NSSound.customSounds.contains(name) {
      soundURL = Bundle.main.url(forResource: name, withExtension: "mp3")
    } else if let appSupportDirectory = fileManager.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first {
      let potentialSoundURL = appSupportDirectory.appendingPathComponent("userImportedSounds")
        .appendingPathComponent(name)
      if fileManager.fileExists(atPath: potentialSoundURL.path) {
        soundURL = potentialSoundURL
      }
    }

    // Play the sound if the URL was found.
    if let soundURL = soundURL {
      NSSound(contentsOf: soundURL, byReference: true)?.play()
    } else {
      print("Sound file not found for name: \(name)")
    }
  }
}
