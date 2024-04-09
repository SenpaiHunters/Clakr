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
  @Published var selectedSoundName: String = {
    UserDefaults.standard.string(forKey: "selectedSoundName") ?? NSSound.systemSounds.first ?? ""
  }()
  @Published var isClicking = false
  private var clickTimer: DispatchSourceTimer?
  private var lastMoved = Date()
  private var mouseMoveMonitor: Any?
  private var rate: TimeInterval = 1.0
  private var stationarySeconds: TimeInterval = 3
  private let eventSource = CGEventSource(stateID: .hidSystemState)
  private var screenHeight: CGFloat = NSScreen.main?.frame.height ?? 0
  private var mouseDownEvent: CGEvent?
  private var mouseUpEvent: CGEvent?
  private var shouldStopClicking = false

  struct AutoClickerPreferences {
    var clicksPerSecond: Double
    var startAfterSeconds: TimeInterval
    var stopAfterSeconds: TimeInterval
    var stationaryForSeconds: TimeInterval
  }

  init() {
    setupKeyboardShortcutListener()
    loadPreferences()
  }

  private func loadPreferences() {
    let defaults = UserDefaults.standard
    let preferences = AutoClickerPreferences(
      clicksPerSecond: defaults.double(forKey: "clicksPerSecond") > 0
        ? defaults.double(forKey: "clicksPerSecond") : 1000.0,
      startAfterSeconds: defaults.double(forKey: "startAfterSeconds") > 0
        ? defaults.double(forKey: "startAfterSeconds") : 3.0,
      stopAfterSeconds: defaults.double(forKey: "stopAfterSeconds") > 0
        ? defaults.double(forKey: "stopAfterSeconds") : 15.0,
      stationaryForSeconds: defaults.double(forKey: "stationaryForSeconds") > 0
        ? defaults.double(forKey: "stationaryForSeconds") : 3.0)
    self.rate = 1.0 / preferences.clicksPerSecond
    self.stationarySeconds = preferences.stationaryForSeconds
  }

  private func setupKeyboardShortcutListener() {
    // This sets up the keyboard shortcut listener.
    KeyboardShortcuts.onKeyUp(for: .toggleAutoClicker) { [weak self] in
      self?.toggleClicking()
    }
  }

  func toggleClicking() {
    isClicking.toggle()

    if playSoundEffects {
      playSound(name: selectedSoundName)
    }

    if isClicking {
      let preferences = fetchUserPreferences(
        defaults: UserDefaults.standard,
        keys: ["clicksPerSecond", "startAfterSeconds", "stopAfterSeconds", "stationaryForSeconds"],
        defaultValues: [1000.0, 3.0, 15.0, 3.0]
      )

      startClicking(
        clicksPerSecond: preferences[0],
        startAfter: preferences[1],
        stopAfter: preferences[2],
        stationaryFor: preferences[3]
      )
    } else {
      stopClicking()
    }
  }

  private func fetchUserPreferences(defaults: UserDefaults, keys: [String], defaultValues: [Double])
    -> [Double]
  {
    return zip(keys, defaultValues).map { key, defaultValue in
      let value = defaults.double(forKey: key)
      return value > 0 ? value : defaultValue
    }
  }

  func startClicking(
    clicksPerSecond: Double, startAfter: TimeInterval, stopAfter: TimeInterval,
    stationaryFor: TimeInterval
  ) {
    self.rate = 1.0 / clicksPerSecond
    self.stationarySeconds = stationaryFor
    self.shouldStopClicking = false  // Reset the stop flag

    // Delay the start of clicking by startAfter seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + startAfter) { [weak self] in
      guard let self = self, !self.shouldStopClicking else { return }
      self.isClicking = true
      self.startTimer()

      // If stopAfter is greater than 0, stop clicking after stopAfter seconds
      if stopAfter > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) {
          guard !self.shouldStopClicking else { return }
          self.stopClicking()
        }
      }
    }

    // Set up mouse move monitor if not already set
    if mouseMoveMonitor == nil {
      mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) {
        [weak self] event in
        guard let self = self, !self.shouldStopClicking else { return }
        self.mouseDidMove(event: event)
      }
    }
  }

  func stopClicking() {
    DispatchQueue.main.async {
      self.isClicking = false
      self.shouldStopClicking = true  // Set the stop flag
    }

    clickTimer?.cancel()
    clickTimer = nil

    if let monitor = mouseMoveMonitor {
      NSEvent.removeMonitor(monitor)
      mouseMoveMonitor = nil
    }
  }

  private func startTimer() {
    clickTimer?.cancel()  // Cancel any existing timer

    // Initialize CGEvents once
    initializeClickEvents()

    clickTimer = DispatchSource.makeTimerSource(
      flags: [.strict], queue: DispatchQueue.global(qos: .userInteractive))
    clickTimer?.schedule(deadline: .now(), repeating: rate, leeway: .milliseconds(1))
    clickTimer?.setEventHandler { [weak self] in
      self?.click()
    }
    clickTimer?.resume()
  }

  private func initializeClickEvents() {
    let point = CGPoint(x: 0, y: 0)  // Temporary point, will be updated on each click
    mouseDownEvent = CGEvent(
      mouseEventSource: eventSource, mouseType: .leftMouseDown, mouseCursorPosition: point,
      mouseButton: .left)
    mouseUpEvent = CGEvent(
      mouseEventSource: eventSource, mouseType: .leftMouseUp, mouseCursorPosition: point,
      mouseButton: .left)
  }

  private func click() {
    guard isClicking, -lastMoved.timeIntervalSinceNow >= stationarySeconds else {
      return
    }

    let mouseLocation = NSEvent.mouseLocation
    let point = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)

    // Update the location of the existing CGEvents
    mouseDownEvent?.location = point
    mouseUpEvent?.location = point

    mouseDownEvent?.post(tap: .cghidEventTap)
    mouseUpEvent?.post(tap: .cghidEventTap)
  }

  private func mouseDidMove(event: NSEvent) {
    lastMoved = Date()
  }

  func playSound(name: String) {
    NSSound(named: NSSound.Name(name))?.play()
  }
}
