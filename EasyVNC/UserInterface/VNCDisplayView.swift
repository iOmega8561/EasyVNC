//
//  VNCDisplayView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import AppKit

final class VNCDisplayView: NSView {
    
    var image: CGImage? {
        didSet {
            DispatchQueue.main.async {
                self.needsDisplay = true
            }
        }
    }

    var client: VNCClient?

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let image = image, let context = NSGraphicsContext.current?.cgContext else { return }

        let rect = bounds
        context.interpolationQuality = .none
        context.draw(image, in: rect)
    }

    override func mouseDown(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 1)
    }

    override func mouseUp(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 0)
    }

    override func mouseDragged(with event: NSEvent) {
        sendMouseEvent(event, buttonMask: 1)
    }

    override func keyDown(with event: NSEvent) {
        client?.sendKey(key: Int(event.keyCode), down: true)
    }

    override func keyUp(with event: NSEvent) {
        client?.sendKey(key: Int(event.keyCode), down: false)
    }

    private func sendMouseEvent(_ event: NSEvent, buttonMask: Int) {
        guard let client = client else { return }
        let location = convert(event.locationInWindow, from: nil)
        let x = Int(location.x)
        let y = Int(bounds.height - location.y) // Flip Y axis
        client.sendMouse(x: x, y: y, buttons: buttonMask)
    }
}
