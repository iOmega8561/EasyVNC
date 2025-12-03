//
//  Copyright (C) 2025  Giuseppe Rocco
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  ----------------------------------------------------------------------
//
//  ClientView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import AppKit

final class ClientView: NSView {
    
    private var keyMonitor: Any?
    private var lastModifierFlags: NSEvent.ModifierFlags = []
    
    var image: CGImage? {
        didSet {
            DispatchQueue.main.async {
                self.needsDisplay = true
            }
        }
    }
    
    var client: ViewModel?
    
    // MARK: - View Lifecycle
    
    override var acceptsFirstResponder: Bool { true }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let image = image, let context = NSGraphicsContext.current?.cgContext else { return }
        
        let rect = bounds
        context.interpolationQuality = .none
        context.draw(image, in: rect)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        // Make this view first responder
        unsafe self.window?.makeFirstResponder(self)
        
        // Install the local event monitor
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { [weak self] event in
            guard let self = self else { return event }
            // Intercept & handle the event ourselves.
            self.handleLocalEvent(event)
            
            // Return nil so it doesn’t propagate to the normal responder chain / menu
            return nil
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        // Remove the local event monitor when the view is detached
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    // MARK: - Event Interception
    
    /// Called by the local event monitor for keyDown, keyUp, and flagsChanged.
    private func handleLocalEvent(_ event: NSEvent) {
        switch event.type {
        case .flagsChanged: flagsChanged(with: event)
        case .keyDown:      keyDown(with: event)
        case .keyUp:        keyUp(with: event)
        default:            break
        }
    }
    
    // MARK: - Keyboard Handling
    
    override func flagsChanged(with event: NSEvent) {
        guard let map = Keys.macModifierMap[event.keyCode] else {
            lastModifierFlags = event.modifierFlags
            return
        }

        let wasPressed = isModifierPressed(event.keyCode, flags: lastModifierFlags)
        let isPressed  = isModifierPressed(event.keyCode, flags: event.modifierFlags)

        if wasPressed != isPressed {
            let sym = isPressed ? map.pressed : map.released
            client?.sendKey(key: Int(sym), down: isPressed)
        }

        lastModifierFlags = event.modifierFlags
    }
    
    override func keyDown(with event: NSEvent) {
        handleKeyEvent(event, down: true)
    }
    
    override func keyUp(with event: NSEvent) {
        handleKeyEvent(event, down: false)
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        // Force all key combos (like cmd+c) to go through keyDown/keyUp
        return false
    }
    
    private func handleKeyEvent(_ event: NSEvent, down: Bool) {
        // “pure” modifiers are managed by flagsChanged
        if Keys.macModifierKeycodes.contains(event.keyCode) { return }

        guard let sym = Keys.keysym(for: event) else { return }

        client?.sendKey(key: Int(sym), down: down)
    }
    
    // MARK: - Mouse Handling
    
    override func mouseDown(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 1)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 4)
    }
    
    override func mouseUp(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 0)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 0)
    }
    
    override func mouseDragged(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 1)
    }
    
    private func sendMouseEvent(_ event: NSEvent, buttonMask: Int) {
        guard let client = client else { return }
        let location = convert(event.locationInWindow, from: nil)
        
        let fbWidth = CGFloat(client.image.width)
        let fbHeight = CGFloat(client.image.height)
        
        let scaleX = fbWidth / bounds.width
        let scaleY = fbHeight / bounds.height
        
        let x = Int(location.x * scaleX)
        let y = Int((bounds.height - location.y) * scaleY) // Flip Y axis
        
        client.sendMouse(x: x, y: y, buttons: buttonMask)
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard let client = client else { return }

        // Framebuffer coords, like in sendMouseEvent(_:)
        let location = convert(event.locationInWindow, from: nil)

        let fbWidth = CGFloat(client.image.width)
        let fbHeight = CGFloat(client.image.height)

        let scaleX = fbWidth / bounds.width
        let scaleY = fbHeight / bounds.height

        let x = Int(location.x * scaleX)
        let y = Int((bounds.height - location.y) * scaleY) // Flip Y

        // VNC: bit 3 = wheel up (8), bit 4 = wheel down (16)
        let buttonScrollUp = 1 << 3    // 8
        let buttonScrollDown = 1 << 4  // 16

        // Using scrollingDeltaY to always have same-unit values
        let dy = event.scrollingDeltaY

        // Base version: one "tick" per event, direction only
        if dy > 0 {
            client.sendMouse(x: x, y: y, buttons: buttonScrollUp)
            client.sendMouse(x: x, y: y, buttons: 0)
        } else if dy < 0 {
            client.sendMouse(x: x, y: y, buttons: buttonScrollDown)
            client.sendMouse(x: x, y: y, buttons: 0)
        }
    }

    // MARK: - Helpers
    
    /// Determine if a certain modifier is pressed based on keyCode + flags.
    private func isModifierPressed(_ keyCode: UInt16, flags: NSEvent.ModifierFlags) -> Bool {
        switch keyCode {
        case 55, 54: return flags.contains(.command)
        case 59, 62: return flags.contains(.control)
        case 58, 61: return flags.contains(.option)
        case 56, 60: return flags.contains(.shift)
        default:
            return false
        }
    }
}
