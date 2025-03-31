//
//  Keys.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

enum Keys {
    
    /// Common Mac keyCodes -> X11 KeySyms
    static let macKeycodeToKeysym: [UInt16: Int] = [
        // Special keys:
        51: 0xff08, // backspace
        36: 0xff0d, // return
        48: 0xff09, // tab
        49: 0x0020, // space
        
        // Arrow keys:
        123: 0xff51, // left
        124: 0xff53, // right
        125: 0xff54, // down
        126: 0xff52, // up
    ]

    /// Common Mac keyCodes for modifiers (we handle these in flagsChanged):
    static let macModifierKeycodes: Set<UInt16> = [
        55, 54,  // command keys
        59, 62,  // control
        58, 61,  // option/alt
        56, 60   // shift
    ]

    /// Mac modifier -> X11 keysym
    static let macModifierMap: [UInt16: (pressed: Int, released: Int)] = [
        55: (0xffeb, 0xffeb), // left command -> Super_L
        54: (0xffec, 0xffec), // right command -> Super_R
        59: (0xffe3, 0xffe3), // left control -> Control_L
        62: (0xffe4, 0xffe4), // right control -> Control_R
        58: (0xffe9, 0xffe9), // left alt -> Alt_L
        61: (0xffea, 0xffea), // right alt -> Alt_R
        56: (0xffe1, 0xffe1), // left shift -> Shift_L
        60: (0xffe2, 0xffe2)  // right shift -> Shift_R
    ]

}
