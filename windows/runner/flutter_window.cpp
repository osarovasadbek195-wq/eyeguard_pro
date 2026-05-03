#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate(HWND hwnd,
                             RECT inset,
                             const std::wstring& title) {
  if (!Win32Window::OnCreate(hwnd, inset, title)) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here is used for the window content area, not including title bar.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  
  RegisterPlugins(flutter_controller_->engine());
  
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  
  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::OnDpiScaleChanged(int dpi_scale) {
  if (flutter_controller_) {
    flutter_controller_->engine()->SetDpiScale(dpi_scale);
  }
}
