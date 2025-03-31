# EasyVNC

**EasyVNC** is a minimal VNC client built in **SwiftUI**, leveraging `libvncclient` from [LibVNCServer](https://github.com/LibVNC/libvncserver) via an Objective-C++ wrapper.

The goal of this project is to provide a lightweight, native macOS VNC viewer with essential functionality and a clean SwiftUI interface.

## 🚀 Features

- 🔌 Connect to a VNC server via IP and port
- 🖥️ Render the remote framebuffer in a SwiftUI view
- 🖱️ Send basic mouse events (click/tap)
- ⌨️ Send basic keyboard input
- 🔓 No authentication required (for now)

## 📦 Tech Stack

- **SwiftUI** for the user interface
- **Objective-C++** bridge for low-level C integration
- **libvncclient** (from LibVNCServer) for VNC protocol handling
- **CoreGraphics** for framebuffer rendering

## 📋 Requirements

- macOS 12.0+
- Xcode 14+
- Dependencies:
  - `libvncclient` (compiled statically)
  - `zlib`
  - `libjpeg` or `libjpeg-turbo`

## 🛠 Build Notes

Make sure to run ```Third-Party/setup-dependencies.sh```, then link the resulting `.a` and headers into your Xcode project
