#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include "resource.h"

namespace {

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

constexpr const unsigned int kTimerId = 100;

// The window procedure that handles messages for the window.
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam,
                         LPARAM lParam) {
  if (message == WM_NCCREATE) {
    auto window = reinterpret_cast<Win32Window*>(
        GetWindowLongPtr(hwnd, GWLP_USERDATA));
    reinterpret_cast<CREATESTRUCT*>(lParam)->lpCreateParams = window;
  }

  auto window =
      reinterpret_cast<Win32Window*>(GetWindowLongPtr(hwnd, GWLP_USERDATA));

  if (window) {
    LRESULT result = window->MessageHandler(hwnd, message, wParam, lParam);
    if (result != 0) {
      return result;
    }
  }

  return DefWindowProc(hwnd, message, wParam, lParam);
}

}  // namespace

Win32Window::Win32Window() {
  ++g_active_window_count;
}

Win32Window::~Win32Window() {
  --g_active_window_count;
  Destroy();
}

bool Win32Window::Create(const std::wstring& title, const Point& origin,
                         const Size& size) {
  Destroy();

  const wchar_t* window_class =
      RegisterWindowClass(reinterpret_cast<HINSTANCE>(&__ImageBase));

  RECT frame = RECT{origin.x, origin.y,
                     origin.x + static_cast<int>(size.width),
                     origin.y + static_cast<int>(size.height)};
  AdjustWindowRect(&frame, WS_OVERLAPPEDWINDOW, false);

  hwnd_ = CreateWindow(
      window_class, title.c_str(), WS_OVERLAPPEDWINDOW,
      frame.left, frame.top, frame.right - frame.left, frame.bottom - frame.top,
      nullptr, nullptr, reinterpret_cast<HINSTANCE>(&__ImageBase), this);

  if (!hwnd_) {
    return false;
  }

  UpdateTheme(hwnd_);

  return OnCreate(hwnd_, inset_, title);
}

bool Win32Window::Show() {
  if (!hwnd_) {
    return false;
  }
  ShowWindow(hwnd_, SW_SHOWNORMAL);
  UpdateWindow(hwnd_);
  return true;

}

void Win32Window::Hide() {
  if (!hwnd_) {
    return;
  }
  ShowWindow(hwnd_, SW_HIDE);
}

void Win32Window::Destroy() {
  if (hwnd_) {
    DestroyWindow(hwnd_);
    hwnd_ = nullptr;
  }
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

RECT Win32Window::GetClientArea() {
  RECT rect;
  GetClientRect(hwnd_, &rect);
  return rect;
}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, hwnd_);
  RECT frame = GetClientArea();
  ::MoveWindow(content, frame.left, frame.top,
               frame.right - frame.left, frame.bottom - frame.top, true);

  ::SetWindowLongPtr(content, GWLP_STYLE,
                    ::GetWindowLongPtr(content, GWLP_STYLE) & ~WS_POPUP);

  ::ShowWindow(content, SW_SHOW);
}

HWND Win32Window::GetHandle() {
  return hwnd_;
}

void Win32Window::SetWindowPosition(const Point& position) {
  SetWindowPos(hwnd_, nullptr, position.x, position.y, 0, 0,
               SWP_NOSIZE | SWP_NOZORDER);
}

void Win32Window::SetWindowSize(const Size& size) {
  RECT frame = RECT{0, 0, static_cast<int>(size.width),
                     static_cast<int>(size.height)};
  AdjustWindowRect(&frame, WS_OVERLAPPEDWINDOW, false);
  ::MoveWindow(hwnd_, frame.left, frame.top,
               frame.right - frame.left, frame.bottom - frame.top, true);
}

void Win32Window::SetTitle(const std::wstring& title) {
  SetWindowText(hwnd_, title.c_str());
}

LRESULT
Win32Window::MessageHandler(HWND hwnd, UINT message, WPARAM wParam,
                            LPARAM lParam) noexcept {
  if (hwnd != hwnd_) {
    return 0;
  }

  switch (message) {
    case WM_SIZE:
      RECT rect = GetClientArea();
      if (child_content_ != nullptr) {
        MoveWindow(child_content_, rect.left, rect.top,
                  rect.right - rect.left, rect.bottom - rect.top, true);
      }
      return 0;

    case WM_TIMER:
      if (wParam == kTimerId) {
        OnTimer();
      }
      return 0;

    case WM_CLOSE:
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_DESTROY:
      OnDestroy();
      return 0;

    default:
      return DefWindowProc(hwnd, message, wParam, lParam);
  }
}

void Win32Window::OnTimer() {}

void Win32Window::OnDestroy() {}

const wchar_t* Win32Window::RegisterWindowClass(HINSTANCE instance) {
  WNDCLASSEXW wcex = {};
  wcex.cbSize = sizeof(WNDCLASSEXW);
  wcex.style = CS_HREDRAW | CS_VREDRAW;
  wcex.lpfnWndProc = WndProc;
  wcex.hInstance = instance;
  wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
  wcex.lpszClassName = kWindowClassName;
  RegisterClassExW(&wcex);
  return kWindowClassName;
}

void Win32Window::UpdateTheme(HWND hwnd) {
  DWORD light_mode;
  DWORD light_mode_size = sizeof(light_mode);
  LSTATUS result = RegGetValueW(
      HKEY_CURRENT_USER,
      L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
      L"AppsUseLightTheme", RRF_RT_REG_DWORD, nullptr, &light_mode,
      &light_mode_size);

  if (result == ERROR_SUCCESS && light_mode == 0) {
    HWND immersive = FindWindowW(L"Windows.UI.Core.CoreWindow", nullptr);
    if (immersive != nullptr) {
      DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE,
                            &light_mode, sizeof(light_mode));
    }
  }
}

int Win32Window::g_active_window_count = 0;
