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

  func startClicking(
    clicksPerSecond: Double, startAfter: TimeInterval, stopAfter: TimeInterval,
    stationaryFor: TimeInterval
  ) {
    self.rate = 1.0 / clicksPerSecond
    self.stationarySeconds = stationaryFor

    // Delay the start of clicking by startAfter seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + startAfter) {
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
      mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
        self?.mouseDidMove()
      }
    }
  }

  func stopClicking() {
    print("stopClicking called")
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
    clickTimer = DispatchSource.makeTimerSource()
    clickTimer?.schedule(deadline: .now(), repeating: rate)
    clickTimer?.setEventHandler { [weak self] in
      self?.click()
    }
    clickTimer?.resume()
  }

  private func click() {
    print("click called")
    guard isClicking, Date().timeIntervalSince(lastMoved) >= stationarySeconds else {
      print(
        "Click skipped: isClicking=\(isClicking), timeIntervalSinceLastMoved=\(Date().timeIntervalSince(lastMoved))"
      )
      return
    }

    let mouseLocation = NSEvent.mouseLocation
    let point = CGPoint(x: mouseLocation.x, y: NSScreen.main!.frame.height - mouseLocation.y)

    guard
      let mouseDownEvent = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point,
        mouseButton: .left),
      let mouseUpEvent = CGEvent(
        mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point,
        mouseButton: .left)
    else {
      print("Failed to create mouse events")
      return
    }

    mouseDownEvent.post(tap: .cghidEventTap)
    mouseUpEvent.post(tap: .cghidEventTap)
  }

  private func mouseDidMove() {
    print("mouseDidMove called")
    lastMoved = Date()
    clickTimer?.cancel()
    clickTimer = nil

    DispatchQueue.main.asyncAfter(deadline: .now() + stationarySeconds) { [weak self] in
      print("Timer restart check after mouse move")
      guard let self = self else { return }

      if self.clickTimer == nil {
        print("Restarting timer")
        self.startTimer()
      }
    }
  }
}
