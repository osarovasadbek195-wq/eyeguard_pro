#include "utils.h"

#include <flutter_windows.h>
#include <io.h>
#include <stdio.h>
#include <windows.h>

#include <iostream>
#include <string>
#include <vector>

// Creates a console for the process, and redirects stdout and stderr to
// it for both the debugger and the terminal.
void CreateAndAttachConsole() {
  // This function is useful for debugging but should not be included in the
  // final product.
  if (::AllocConsole()) {
    FILE *stdin_handle, *stdout_handle, *stderr_handle;
    freopen_s(&stdin_handle, "CONIN$", "r", stdin);
    freopen_s(&stdout_handle, "CONOUT$", "w", stdout);
    freopen_s(&stderr_handle, "CONOUT$", "w", stderr);
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);
  }
}

std::vector<std::string> GetCommandLineArguments() {
  // Convert the UTF-16 command line arguments to UTF-8 for the Engine to use.
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return std::vector<std::string>();
  }

  std::vector<std::string> command_line_arguments;

  for (int i = 0; i < argc; ++i) {
    command_line_arguments.push_back(Utf8FromUtf16(argv[i]));
  }

  ::LocalFree(argv);

  return command_line_arguments;
}

std::string Utf8FromUtf16(const wchar_t* utf16_string) {
  if (utf16_string == nullptr) {
    return std::string();
  }
  int target_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      -1, nullptr, 0, nullptr, nullptr);
  if (target_length == 0 || target_length > INT_MAX) {
    return std::string();
  }
  std::string utf8_string;
  utf8_string.resize(target_length);
  int converted_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      -1, utf8_string.data(), target_length,
      nullptr, nullptr);
  if (converted_length == 0) {
    return std::string();
  }
  return utf8_string;
}
