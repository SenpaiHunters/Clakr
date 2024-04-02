//
//  AutoClicker.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import Cocoa
import Foundation

class AutoClicker: ObservableObject {
  private var clickTimer: DispatchSourceTimer?
  @Published var isClicking = false
  private var lastMoved = Date()
  private var mouseMoveMonitor: Any?
  var rate: TimeInterval = 1.0
  var stationarySeconds: TimeInterval = 3
  private let eventSource = CGEventSource(stateID: .hidSystemState)
  private var screenHeight: CGFloat = NSScreen.main?.frame.height ?? 0
  private var mouseDownEvent: CGEvent?
  private var mouseUpEvent: CGEvent?

  func startClicking(
    clicksPerSecond: Double, startAfter: TimeInterval, stopAfter: TimeInterval,
    stationaryFor: TimeInterval
  ) {
    self.rate = 1.0 / clicksPerSecond
    self.stationarySeconds = stationaryFor

    // Delay the start of clicking by startAfter seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + startAfter) { [weak self] in
      guard let self = self else { return }
      self.isClicking = true
      self.startTimer()

      // If stopAfter is greater than 0, stop clicking after stopAfter seconds
      if stopAfter > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) {
          self.stopClicking()
        }
      }
    }

    // Set up mouse move monitor if not already set
    if mouseMoveMonitor == nil {
      mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) {
        [weak self] event in
        self?.mouseDidMove(event: event)
      }
    }
  }

  func stopClicking() {
    // print("stopClicking called")
    DispatchQueue.main.async {
      self.isClicking = false
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
    // print("mouseDidMove called")
    lastMoved = Date()
  }
}
