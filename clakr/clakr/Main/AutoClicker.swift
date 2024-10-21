//
//  AutoClicker.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import Cocoa
import KeyboardShortcuts

class AutoClicker: ObservableObject {
    @Published var playSoundEffects: Bool
    @Published var selectedSoundName: String
    @Published var isClicking = false

    private static let timerQueue = DispatchQueue(label: "com.clakr.autoclicker.timer", qos: .utility)
    private let eventSource = CGEventSource(stateID: .hidSystemState)
    private let screenHeight: CGFloat

    private var clickTimer: DispatchSourceTimer?
    private var lastMoved = Date()
    private var mouseMoveMonitor: Any?
    private var rate: TimeInterval
    private var stationarySeconds: TimeInterval
    private var mouseDownEvent: CGEvent?
    private var mouseUpEvent: CGEvent?
    private var shouldStopClicking = false
    private var appBlacklist: [String: BlacklistedApp]

    private let defaults = UserDefaults.standard

    init() {
        self.playSoundEffects = defaults.bool(forKey: "playSoundEffects")
        self.selectedSoundName = defaults.string(forKey: "selectedSoundName") ?? NSSound.systemSounds.first ?? ""
        self.screenHeight = NSScreen.main?.frame.height ?? 500

        // Initialize rate and stationarySeconds with default values
        self.rate = 1.0 / 1000.0 // Default to 1000 clicks per second
        self.stationarySeconds = 3.0 // Default to 3 seconds

        // Initialize appBlacklist with a default value
        self.appBlacklist = ["com.kami.clakr": BlacklistedApp(name: "clakr", bundleID: "com.kami.clakr")]

        // Now that all properties are initialized, we can use 'self'
        let preferences = loadPreferences()
        self.rate = 1.0 / preferences.clicksPerSecond
        self.stationarySeconds = preferences.stationaryForSeconds

        self.appBlacklist = loadBlacklist()

        setupKeyboardShortcutListener()
    }

    private func loadBlacklist() -> [String: BlacklistedApp] {
        let appBlacklistString = defaults.string(forKey: "appBlacklistString") ?? ""
        if let blacklistArray = Array<BlacklistedApp>.from(jsonString: appBlacklistString) {
            return Dictionary(uniqueKeysWithValues: blacklistArray.map { ($0.bundleID, $0) })
        } else {
            print("Failed to decode app blacklist. Using default.")
            return ["com.kami.clakr": BlacklistedApp(name: "clakr", bundleID: "com.kami.clakr")]
        }
    }

    private func isCurrentAppBlacklisted() -> Bool {
        guard let activeApp = NSWorkspace.shared.frontmostApplication,
              let activeAppBundleID = activeApp.bundleIdentifier else {
            print("Failed to retrieve active application details.")
            return false
        }
        return appBlacklist[activeAppBundleID] != nil
    }

    private struct AutoClickerPreferences {
        let clicksPerSecond: Double
        let startAfterSeconds: TimeInterval
        let stopAfterSeconds: TimeInterval
        let stationaryForSeconds: TimeInterval
    }

    private func loadPreferences() -> AutoClickerPreferences {
        let keys = ["clicksPerSecond", "startAfterSeconds", "stopAfterSeconds", "stationaryForSeconds"]
        let defaultValues = [1000.0, 2.0, 15.0, 3.0]

        for (key, defaultValue) in zip(keys, defaultValues) {
            if defaults.object(forKey: key) == nil {
                defaults.set(defaultValue, forKey: key)
            }
        }

        return AutoClickerPreferences(
            clicksPerSecond: defaults.double(forKey: keys[0]),
            startAfterSeconds: defaults.double(forKey: keys[1]),
            stopAfterSeconds: defaults.double(forKey: keys[2]),
            stationaryForSeconds: defaults.double(forKey: keys[3])
        )
    }

    private func setupKeyboardShortcutListener() {
        KeyboardShortcuts.onKeyUp(for: .toggleAutoClicker) { [weak self] in
            self?.toggleClicking()
        }
    }

    func toggleClicking() {
        guard !isCurrentAppBlacklisted() else {
            print("Active application is blacklisted. Auto-clicker will not be toggled.")
            return
        }

        isClicking.toggle()

        if playSoundEffects {
            playSound(name: selectedSoundName)
        }

        isClicking ? startClicking() : stopClicking()
    }

    private func startClicking() {
        let preferences = loadPreferences()
        rate = 1.0 / preferences.clicksPerSecond
        stationarySeconds = preferences.stationaryForSeconds
        shouldStopClicking = false

        DispatchQueue.main.asyncAfter(deadline: .now() + preferences.startAfterSeconds) { [weak self] in
            guard let self, !self.shouldStopClicking else { return }
            isClicking = true
            startTimer()

            if preferences.stopAfterSeconds > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + preferences.stopAfterSeconds) {
                    guard !self.shouldStopClicking else { return }
                    self.stopClicking()
                }
            }
        }

        setupMouseMoveMonitor()
    }

    private func setupMouseMoveMonitor() {
        guard mouseMoveMonitor == nil else { return }
        mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            self?.lastMoved = Date()
        }
    }

    func stopClicking() {
        isClicking = false
        shouldStopClicking = true

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
        guard isClicking, -lastMoved.timeIntervalSinceNow >= stationarySeconds else { return }

        let mouseLocation = NSEvent.mouseLocation
        let newPoint = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)

        mouseDownEvent = mouseDownEvent ?? createMouseEvent(type: .leftMouseDown, point: newPoint)
        mouseUpEvent = mouseUpEvent ?? createMouseEvent(type: .leftMouseUp, point: newPoint)

        mouseDownEvent?.location = newPoint
        mouseUpEvent?.location = newPoint

        mouseDownEvent?.post(tap: .cghidEventTap)
        mouseUpEvent?.post(tap: .cghidEventTap)
    }

    private func createMouseEvent(type: CGEventType, point: CGPoint) -> CGEvent? {
        CGEvent(mouseEventSource: eventSource, mouseType: type, mouseCursorPosition: point, mouseButton: .left)
    }

    func playSound(name: String) {
        let fileManager = FileManager.default
        let soundURL: URL? = if NSSound.systemSounds.contains(name) {
            URL(fileURLWithPath: "/System/Library/Sounds").appendingPathComponent(name).appendingPathExtension("aiff")
        } else if NSSound.customSounds.contains(name) {
            Bundle.main.url(forResource: name, withExtension: "mp3")
        } else if let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            appSupportDirectory.appendingPathComponent("userImportedSounds").appendingPathComponent(name)
        } else {
            nil
        }

        if let url = soundURL, fileManager.fileExists(atPath: url.path) {
            NSSound(contentsOf: url, byReference: true)?.play()
        } else {
            print("Sound file not found for name: \(name)")
        }
    }
}
