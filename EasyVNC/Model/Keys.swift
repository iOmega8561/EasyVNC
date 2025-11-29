//
//  Keys.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import AppKit

enum Keys {
    
    /// Mac virtual keyCode -> X11 keysym
    static let specialKeycodeToKeysym: [UInt16: UInt32] = [
        
        // Control keys
        53: 0xff1b, // Esc
        36: 0xff0d, // Return
        51: 0xff08, // Backspace
        71: 0xff9c, // Clear
        76: 0xff8d, // Keypad Enter

        // Arrows
        123: 0xff51, // Left
        124: 0xff53, // Right
        125: 0xff54, // Down
        126: 0xff52, // Up

        // Home / End / PageUp / PageDown
        115: 0xff50, // Home
        119: 0xff57, // End
        116: 0xff55, // PageUp
        121: 0xff56, // PageDown

        // Insert / Delete (forward delete)
        114: 0xff63, // Insert
        117: 0xffff, // Delete (forward)

        // Function keys (F1–F12)
        122: 0xffbe, // F1
        120: 0xffbf, // F2
        99:  0xffc0, // F3
        118: 0xffc1, // F4
        96:  0xffc2, // F5
        97:  0xffc3, // F6
        98:  0xffc4, // F7
        100: 0xffc5, // F8
        101: 0xffc6, // F9
        109: 0xffc7, // F10
        103: 0xffc8, // F11
        111: 0xffc9, // F12
    ]

    /// Mac modifier keyCodes (flagsChanged)
    static let macModifierKeycodes: Set<UInt16> = [
        55, 54,  // command
        59, 62,  // control
        58, 61,  // option/alt
        56, 60   // shift
    ]

    /// Mac modifier -> X11 keysym (pressed/released)
    static let macModifierMap: [UInt16: (pressed: UInt32, released: UInt32)] = [
        55: (0xffeb, 0xffeb), // left command -> Super_L
        54: (0xffec, 0xffec), // right command -> Super_R
        59: (0xffe3, 0xffe3), // left control -> Control_L
        62: (0xffe4, 0xffe4), // right control -> Control_R
        58: (0xffe9, 0xffe9), // left alt -> Alt_L
        61: (0xffea, 0xffea), // right alt -> Alt_R
        56: (0xffe1, 0xffe1), // left shift -> Shift_L
        60: (0xffe2, 0xffe2)  // right shift -> Shift_R
    ]

    /// NSEvent keyDown/keyUp to keysym X11
    static func keysym(for event: NSEvent) -> UInt32? {
        
        // 1. If it's special key mapped by keyCode, use that directly
        if let special = specialKeycodeToKeysym[event.keyCode] {
            return special
        }

        // 2. Try to use the generated character otherwise.
        //    Using charactersIgnoringModifiers so that CTRL, CND don't mess up the ch.
        guard let chars = event.charactersIgnoringModifiers,
              let scalar = chars.unicodeScalars.first
        else {
            return nil
        }

        let u = scalar.value

        // X11 rule: keySym matches codepoint for latin-1 characters (<= 0xFF)
        if u <= 0x00ff {
            return UInt32(u)
        }

        // bit 0x01000000 for Unicode over 0xFF 
        return 0x01000000 | UInt32(u)
    }
}
