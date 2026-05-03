#ifndef FLUTTER_WINDOW_H_
#define FLUTTER_WINDOW_H_

#include <flutter/flutter_view_controller.h>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate(HWND hwnd,
               RECT inset,
               const std::wstring& title) override;
  void OnDestroy() override;
  LRESULT WndProc(UINT message,
                  WPARAM wparam,
                  LPARAM lparam) noexcept override;

 private:
  // The Flutter controller
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // FLUTTER_WINDOW_H_
