#ifndef WIN32_WINDOW_H_
#define WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// A class abstraction for a Win32 Window.
class Win32Window {
 public:
  struct Point {
    int x;
    int y;
    Point(int x = 0, int y = 0) : x(x), y(y) {}
  };

  struct Size {
    int width;
    int height;
    Size(int width = 0, int height = 0) : width(width), height(height) {}
  };

  Win32Window();
  ~Win32Window();

  // Creates and shows a win32 window with |title| and position and size using
  // |origin| and |size|. New windows are created on the default monitor. Window
  // sizes are specified to the OS in physical pixels, hence to ensure a
  // consistent size to will treat the values as logical pixels and scale to
  // appropriate for the default monitor. Returns true if the window was created
  // successfully.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // Show the current window. Returns true if the window was successfully shown.
  bool Show();

  // Release OS resources associated with window.
  void Destroy();

  // Inserts |content| into the window tree.
  void SetChildContent(HWND content);

  // Returns the backing Window handle to return to other Flutter code.
  HWND GetHandle();

  // If true, closing this window will quit the application.
  void SetQuitOnClose(bool quit_on_close);

  // Returns true if this window is currently the foreground window.
  bool IsOnForeground();

 protected:
  // Processes and route salient window messages for the window.
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                        LPARAM const lparam) noexcept;

  // Called when a pointer is hovering over the window.
  void OnPointerMove(int x, int y);

  // Called when the window is resized.
  void OnResize(int width, int height);

  // Called when the window receives a timer event.
  void OnTimer();

  // Called when the window is being closed.
  void OnDestroy();

  // Callback for the window creation.
  virtual bool OnCreate(HWND hwnd, RECT inset, const std::wstring& title);

  // Callback for the window destruction.
  virtual void OnDestroyInternal();

  // The window class name.
  static const wchar_t kWindowClassName[];

 private:
  // The window handle.
  HWND hwnd_ = nullptr;

  // The child content.
  HWND child_content_ = nullptr;

  // True if this window is currently the foreground window.
  bool is_on_foreground_ = false;

  // If true, closing this window will quit the application.
  bool quit_on_close_ = false;

  // The inset of the window frame.
  RECT inset_ = {0};

  // The number of currently active windows.
  static int g_active_window_count;

  // Updates the window theme based on system settings.
  void UpdateTheme(HWND hwnd);
};

#endif  // WIN32_WINDOW_H_
