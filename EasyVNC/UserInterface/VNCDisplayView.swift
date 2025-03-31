//
//  VNCDisplayView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import AppKit

final class VNCDisplayView: NSView {
    
    private var keyMonitor: Any?
    private var lastModifierFlags: NSEvent.ModifierFlags = []
    
    var image: CGImage? {
        didSet {
            DispatchQueue.main.async {
                self.needsDisplay = true
            }
        }
    }
    
    var client: VNCClient?
    
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
        self.window?.makeFirstResponder(self)
        
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
        case .flagsChanged:
            flagsChanged(with: event)
        case .keyDown:
            keyDown(with: event)
        case .keyUp:
            keyUp(with: event)
        default:
            break
        }
    }
    
    // MARK: - Keyboard Handling
    
    override func flagsChanged(with event: NSEvent) {
        // If this is a recognized modifier key, handle it
        if let (pressedSym, _) = Keys.macModifierMap[event.keyCode] {
            // Compare old/new flags
            let wasPressed = isModifierPressed(event.keyCode, flags: lastModifierFlags)
            let isPressed  = isModifierPressed(event.keyCode, flags: event.modifierFlags)
            if wasPressed != isPressed {
                client?.sendKey(key: pressedSym, down: isPressed)
            }
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
        // If it's a recognized modifier, do nothing here. flagsChanged handles it.
        if Keys.macModifierKeycodes.contains(event.keyCode) { return }
        
        // If it's a known special key
        if let sym = Keys.macKeycodeToKeysym[event.keyCode] {
            client?.sendKey(key: sym, down: down)
            return
        }
        
        // Else try using the characters
        if let chars = event.charactersIgnoringModifiers, let scalar = chars.unicodeScalars.first {
            let val = Int(scalar.value)
            client?.sendKey(key: val, down: down)
        }
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
        
        let fbWidth = CGFloat(client.image?.width ?? Int(bounds.width))
        let fbHeight = CGFloat(client.image?.height ?? Int(bounds.height))
        
        let scaleX = fbWidth / bounds.width
        let scaleY = fbHeight / bounds.height
        
        let x = Int(location.x * scaleX)
        let y = Int((bounds.height - location.y) * scaleY) // Flip Y axis
        
        client.sendMouse(x: x, y: y, buttons: buttonMask)
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
