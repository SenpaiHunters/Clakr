//
//  Main.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import Cocoa

@main
struct Main {
    static func main() {
        let appDelegate = AppDelegate()
        NSApp.delegate = appDelegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}
