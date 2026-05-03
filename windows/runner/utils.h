#ifndef UTILS_H_
#define UTILS_H_

#include <string>
#include <vector>

// Creates a console for the process, and redirects stdout and stderr to
// it for both the debugger and terminal.
void CreateAndAttachConsole();

// Returns the command line arguments for the process in UTF-8.
std::vector<std::string> GetCommandLineArguments();

// Converts a UTF-16 string to UTF-8.
std::string Utf8FromUtf16(const wchar_t* utf16_string);

#endif  // UTILS_H_
